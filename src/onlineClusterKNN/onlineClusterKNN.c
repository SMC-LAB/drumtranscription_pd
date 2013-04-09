/*
 
 onlineClusterKNN - An sequential k-means classification external.
 http://www.cs.princeton.edu/courses/archive/fall08/cos436/Duda/C/sk_means.htm
 
 by Marius Miron (INESC Porto) miron.marius[at]gmail[dot]com
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 Please contact miron.marius[at]gmail[dot]com for further questions. 
 
*/


#include "m_pd.h"
#include <math.h>
#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#define MAXCLUSTERMEMS 8192

static t_class *onlineClusterKNN_class;

typedef struct instance
{
    float *instance;
    int cluster;
} t_instance;

typedef struct _onlineClusterKNN
{
	t_object  x_obj;
    t_instance *means; //means for each cluster
    int *num; //counter of instances for each cluster
    
    t_instance *instances;
	t_float *featureInput;
    int *instanceFeatureLengths;
    int featureLength;
    int numInstances;
    int numClusters;
    int distMetric; 
    int randomFlag;
    int memory;
    
    t_outlet *id;
} t_onlineClusterKNN;

/* ---------------- utility functions ---------------------- */
static void printv(t_float *v, int listLength)
{
    int i;
    
    for(i=0; i<listLength; i++)
       post("%i - %6.20f", i, v[i]);
    
}

int countDigits(int num){
    int count=0;
        
    while(num>0){
        num=num/10;
        count++;
    }
    
    return count;
}

static int test_zero(t_float *newelement, int numfeatures)
{
	int i,b;
    b=0;
	for(i=0; i<numfeatures; i++)
	{		
        if (newelement[i]!=0) {b=1;break;}
    }            
    return(b);
}

/*static t_instance compute_mean(t_instance mean, t_instance newelement, int numfeatures, int numelements)
{
	int i;
	t_instance newmean;
    
    newmean.instance = (t_float *)t_getbytes(numfeatures * sizeof(t_float));     
	for(i=0; i<numfeatures; i++)
	{		
        newmean.instance[i] = mean.instance[i] +(1/numelements) * (newelement.instance[i] - mean.instance[i]);
	}
	
	return(newmean);
}
 */

static void compute_mean(t_onlineClusterKNN *x, int k, t_instance newelement)
{
	int i;
    
	for(i=0; i<x->featureLength; i++)
	{	
        if (x->memory == 0)
            x->means[k].instance[i] = x->means[k].instance[i] + (newelement.instance[i] - x->means[k].instance[i])/x->num[k];
        else x->means[k].instance[i] = x->means[k].instance[i] + (newelement.instance[i] - x->means[k].instance[i])/x->memory;
	}
}

static t_float squared_euclid(t_float *v1, t_float *v2, int numfeatures)
{
	int i;
	t_float sum, dist;
	
	sum=dist=0;
	for(i=0; i < numfeatures; i++)
	{
        sum = sum + pow((v1[i]-v2[i]),2.0);	
    }
    dist = sqrt(sum);
	return(dist);
}

/* ---------------- END utility functions ---------------------- */


static void onlineClusterKNN_print(t_onlineClusterKNN *x)
{
	post("no. of instances: %i", x->numInstances);
	post("feature length: %i", x->featureLength);	
	post("distance metric: %i", x->distMetric);
	post("no. of clusters: %i", x->numClusters);
    post("initialize with random means: %i", x->randomFlag);
	
}

static void onlineClusterKNN_cluster(t_onlineClusterKNN *x, t_symbol *s, int argc, t_atom *argv)
{
    int i, j, k, instanceIdx, listLength;
    float min_dist,dist;
    
	instanceIdx = x->numInstances;
	listLength = argc;
	s=s; // to get rid of 'unused variable' warning
    //post("list length: %i", listLength);
    
    if((x->featureLength>0) && (x->featureLength != listLength))
	{
        post("received list of length %i and expected %i", listLength, x->featureLength); 
        return;
    }    
    
	x->instances = (t_instance *)t_resizebytes(x->instances, x->numInstances * sizeof(t_instance), (x->numInstances+1) * sizeof(t_instance));
	x->instanceFeatureLengths = (int *)t_resizebytes(x->instanceFeatureLengths, x->numInstances * sizeof(int), (x->numInstances+1) * sizeof(int));
	
	x->instanceFeatureLengths[instanceIdx] = listLength;
	x->instances[instanceIdx].instance = (t_float *)t_getbytes(listLength * sizeof(t_float));    
		
	x->numInstances++;
	//post("no. of instances: %i", x->numInstances);          
   
    
    //get the data
	for(i=0; i<listLength; i++)
		x->instances[instanceIdx].instance[i] = atom_getfloat(argv+i);
    
    //test if received element is zeros vector
    if (test_zero(x->instances[instanceIdx].instance,listLength) == 0)
    {
        //post("instance cannot be zeros vector");
        //rollback
        t_freebytes(x->instances[instanceIdx].instance, x->instanceFeatureLengths[instanceIdx]*sizeof(t_float));
        x->instances = (t_instance *)t_resizebytes(x->instances, x->numInstances * sizeof(t_instance), (x->numInstances-1) * sizeof(t_instance));
        x->instanceFeatureLengths = (int *)t_resizebytes(x->instanceFeatureLengths, x->numInstances * sizeof(int), (x->numInstances-1) * sizeof(int)); 
        
        x->numInstances--;
        
    }
    else 
    {
    
    if(instanceIdx == 0)
	{
		x->featureInput = (t_float *)t_resizebytes(x->featureInput, x->featureLength * sizeof(t_float), listLength * sizeof(t_float));		
		x->featureLength = listLength;  
        
        x->num = (int *)t_resizebytes(x->num, 0 * sizeof(int), x->numClusters * sizeof(int));
        
		// initialize means randomly for each cluster        
        for(i=0; i<x->numClusters; i++)
        {
            x->means = (t_instance *)t_resizebytes(x->means, i * sizeof(t_instance), (i+1) * sizeof(t_instance));
            x->means[i].instance = (t_float *)t_getbytes(listLength * sizeof(t_float)); 
            
            if (x->randomFlag == 1)
            {
                for(j=0; j<listLength; j++)
                {
                    srand(i*j+i+j+1);
                    x->means[i].instance[j] = (float)rand()/(float)RAND_MAX;            
                }
            }
        }                
        // initialize number of instances for each cluster
		for(i=0; i<x->numClusters; i++)
			x->num[i] = 0;
    };

    
    //normalize the data to be 0-1
    for(i=0; i<listLength; i++)
		if (x->instances[instanceIdx].instance[i]>1)
        {            
            x->instances[instanceIdx].instance[i] = x->instances[instanceIdx].instance[i] * pow(10,-countDigits((int)(x->instances[instanceIdx].instance[i])));
        }
    
    //////////////ONLINE CLUSTERING
    
    //initialize means with the first instances if random==0
    if ((x->randomFlag == 0) && (instanceIdx < x->numClusters))
    {
        for(j=0; j<listLength; j++)
        {
            x->means[instanceIdx].instance[j] =  x->instances[instanceIdx].instance[j];
        }
        x->instances[instanceIdx].cluster = instanceIdx;
        x->num[instanceIdx] = 1;
    }
    else
    {        
    //compute distances to the means and determine the closest cluster 
        min_dist = 99999999;
        k = -1;
        for(i=0; i<x->numClusters; i++)
        { 
            dist = squared_euclid(x->means[i].instance,x->instances[instanceIdx].instance,listLength);
            //post("%6.20f", dist);
            if (dist < min_dist)
            {
                min_dist = dist;
                k = i;
            }
        }   
        
    //add the new instance to the found cluster
        //post("cluster %i", k);
        if (k != -1)
        {
            x->num[k] = x->num[k] + 1;
            //x->means[k] = compute_mean(x->means[k],x->instances[instanceIdx],listLength,x->num[k]);
            compute_mean(x, k, x->instances[instanceIdx]);
            x->instances[instanceIdx].cluster = k;     
        }  
    }
	
	outlet_float(x->id, x->instances[instanceIdx].cluster);    
    }
}

static void onlineClusterKNN_random(t_onlineClusterKNN  *x, t_floatarg r)
{
	r = (r<0)?0:r;
	r = (r>1)?1:r;
	x->randomFlag = r;
    post("randomize initial means: %i", x->randomFlag);
}

static void onlineClusterKNN_memory(t_onlineClusterKNN  *x, t_floatarg r)
{
    r = (r<0)?0:r;
	x->memory = (int)r;
    post("online memory: %i", x->memory);
}

static void onlineClusterKNN_clear(t_onlineClusterKNN *x)
{
	int i,j;	
    
    if (x->randomFlag == 1)
    {
        // free the database memory
        for(i=0; i<x->numInstances; i++)
            t_freebytes(x->instances[i].instance, x->instanceFeatureLengths[i]*sizeof(t_float));
        
        for(i=0; i<x->numClusters; i++)
            t_freebytes(x->means[i].instance, x->instanceFeatureLengths[0]*sizeof(t_float));
        
        x->instances = (t_instance *)t_resizebytes(x->instances, x->numInstances * sizeof(t_instance), 0);
        x->means = (t_instance *)t_resizebytes(x->means, x->numClusters * sizeof(t_instance), 0);
        x->num = (int *)t_resizebytes(x->num, x->numClusters * sizeof(int), 0);
        x->numInstances = 0;
        x->featureLength = 0;
        x->instanceFeatureLengths = (int *)t_resizebytes(x->instanceFeatureLengths, x->numInstances * sizeof(int), 0);	
    }
    else
    {              
        for(i=0; i<x->numClusters; i++)
        {
           for(j=0; j<x->featureLength; j++)
           {
                x->means[i].instance[j] =  x->instances[i].instance[j];
           }
           x->num[i] = 1;
        }
        
        // free the database memory
        for(i=x->numClusters; i<x->numInstances; i++)
            t_freebytes(x->instances[i].instance, x->instanceFeatureLengths[i]*sizeof(t_float));
        
        x->instances = (t_instance *)t_resizebytes(x->instances, x->numInstances * sizeof(t_instance), x->numClusters * sizeof(t_instance));
        x->numInstances = x->numClusters;
        x->instanceFeatureLengths = (int *)t_resizebytes(x->instanceFeatureLengths, x->numInstances * sizeof(int), x->numClusters * sizeof(int));	        
    }   
		
    post("all instances cleared.");
}


static void onlineClusterKNN_free(t_onlineClusterKNN *x)
{
	int i;
    i = 0;        
    
	// free the database memory
	for(i=0; i<x->numInstances; i++)
		t_freebytes(x->instances[i].instance, x->instanceFeatureLengths[i]*sizeof(t_float));
    
    for(i=0; i<x->numClusters; i++)
		t_freebytes(x->means[i].instance, x->instanceFeatureLengths[0]*sizeof(t_float));
    
    t_freebytes(x->means, x->numClusters*sizeof(t_instance));
    t_freebytes(x->num, x->numClusters*sizeof(int));    
	
	t_freebytes(x->instances, x->numInstances*sizeof(t_instance)); 
	
	t_freebytes(x->featureInput, x->featureLength*sizeof(t_float));
	t_freebytes(x->instanceFeatureLengths, x->numInstances*sizeof(int));	
    
}

static void *onlineClusterKNN_new(t_float nrclusters)
{
	t_onlineClusterKNN *x = (t_onlineClusterKNN *)pd_new(onlineClusterKNN_class);
    
    x->id = outlet_new(&x->x_obj, &s_float);
    
    x->means = (t_instance *)t_getbytes(0);
    x->num = (int *)t_getbytes(0);
    
    x->instances = (t_instance *)t_getbytes(0);
    x->instanceFeatureLengths = (int *)t_getbytes(0);
    x->featureInput = (t_float *)t_getbytes(0);
	
	x->featureLength = 0;
	
    x->numInstances = 0;
    x->distMetric = 0;  // euclidean distance by default
    x->randomFlag = 1;  //initialize the knn means with random values by default
    x->memory = 0; // infinite memory
    if (nrclusters)
    {
        nrclusters = (nrclusters>10)?10:nrclusters;
        nrclusters = (nrclusters<2)?2:nrclusters;
        x->numClusters = (int)nrclusters;
    }
    else x->numClusters=2; //2 clusters minimum
   
	post("onlineClusterKNN version 0.1.0");
    post("number of clusters: %i", x->numClusters);
    return (x);
    //return (void *)x;
}


void onlineClusterKNN_setup(void) {
    
	onlineClusterKNN_class = class_new(gensym("onlineClusterKNN"),
                                 (t_newmethod)onlineClusterKNN_new,
                                 (t_method)onlineClusterKNN_free,
                                 sizeof(t_onlineClusterKNN),
                                 CLASS_DEFAULT,
                                 A_DEFFLOAT,
                                 0
                                 );
    
	class_addlist(onlineClusterKNN_class, onlineClusterKNN_cluster);
  
    class_addmethod(onlineClusterKNN_class, 
                    (t_method)onlineClusterKNN_random,
                    gensym("random"),
                    A_DEFFLOAT,
                    0
                    );
    
    class_addmethod(onlineClusterKNN_class, 
                    (t_method)onlineClusterKNN_memory,
                    gensym("memory"),
                    A_DEFFLOAT,
                    0
                    );
    
    class_addmethod(onlineClusterKNN_class, 
                    (t_method)onlineClusterKNN_clear,
                    gensym("clear"),
                    0
                    );  
    
    class_addmethod(onlineClusterKNN_class, 
                    (t_method)onlineClusterKNN_print,
                    gensym("print"),
                    0
                    );

}


