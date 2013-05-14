/*

featureMean - an external for computing the mean of multiple feature frames over time.
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

static t_class *featureMean_class;

typedef struct instance
{
    float *instance;
} t_instance;

typedef struct _featureMean
{
	t_object  x_obj;
    t_instance *instances;
    t_atom *x_listOut;
	int featureLength;
	int numFrames;
	int currentFrame;
    t_outlet *featureList;
} t_featureMean;


static void featureMean_accum(t_featureMean *x, t_symbol *s, int argc, t_atom *argv)
{
	int i, j;
    float sum;
    
    if (argc>0)
    {             
        if(x->featureLength != argc)
            error("featureMean: input length does not match current length setting. input ignored.");
        else
        {
            x->instances[x->currentFrame].instance = (float *)t_getbytes(x->featureLength*sizeof(float));
            for(i=0; i<x->featureLength; i++)
                x->instances[x->currentFrame].instance[i] = atom_getfloat(argv+i);
        
        x->currentFrame++;
        
        if (x->currentFrame==x->numFrames) 
        {
            for(i=0; i<x->featureLength; i++)
            {
                sum = 0;
                for(j=0; j<x->currentFrame; j++) 
                {
                    sum = sum + x->instances[j].instance[i];
                }
                sum = sum / x->currentFrame;
                SETFLOAT(x->x_listOut+i, sum); 
            }
            
            outlet_list(x->featureList, 0, x->featureLength, x->x_listOut);
            
            x->currentFrame = (x->currentFrame==x->numFrames)?0:x->currentFrame;
        }
        }
    }

}

static void featureMean_bang(t_featureMean *x)
{
    int i, j;
    float sum;
    
    if (x->currentFrame>0) 
    {
        for(i=0; i<x->featureLength; i++)
        {
            sum = 0;
            for(j=0; j<x->currentFrame; j++) 
            {
                sum = sum + x->instances[j].instance[i];
            }
            sum = sum / x->currentFrame;
            SETFLOAT(x->x_listOut+i, sum); 
        }
        
        outlet_list(x->featureList, 0, x->featureLength, x->x_listOut);
        
        x->currentFrame = 0;
        
    }
}

static void featureMean_clear(t_featureMean *x)
{
	int i, j;
    
	// free the database memory
	for(i=0; i<x->numFrames; i++)
		t_freebytes(x->instances[i].instance, x->featureLength*sizeof(float));
    
	t_freebytes(x->instances, x->numFrames*sizeof(t_instance));
    
	x->currentFrame = 0;
    
    for(i=0; i<x->featureLength; i++)
         SETFLOAT(x->x_listOut+i, 0.0);
    
    x->instances = (t_instance *)t_getbytes(x->numFrames*sizeof(t_instance));
    
	for(i=0; i<x->numFrames; i++)
		x->instances[i].instance = (float *)t_getbytes(x->featureLength*sizeof(float));
    
	for(i=0; i<x->numFrames; i++)
		for(j=0; j<x->featureLength; j++)
			x->instances[i].instance[j] = 0.0;
}

static void featureMean_numFrames(t_featureMean *x, t_floatarg num)
{
    int i, j;
    
	if(num)
	{
        //x->x_listOut = (t_atom *)t_resizebytes(x->x_listOut, (x->featureLength-1)*sizeof(t_atom), (x->featureLength*num)*sizeof(t_atom));
        
		// free the database memory
		for(i=0; i<x->numFrames; i++)
			t_freebytes(x->instances[i].instance, x->featureLength*sizeof(float));
        
		t_freebytes(x->instances, x->numFrames*sizeof(t_instance));
        
		x->currentFrame = 0;
		x->numFrames = num;
        
        for(i=0; i<x->featureLength; i++)
	        SETFLOAT(x->x_listOut+i, 0.0);
        
		x->instances = (t_instance *)t_getbytes(x->numFrames*sizeof(t_instance));
        
		for(i=0; i<x->numFrames; i++)
			x->instances[i].instance = (float *)t_getbytes(x->featureLength*sizeof(float));
        
		for(i=0; i<x->numFrames; i++)
			for(j=0; j<x->featureLength; j++)
				x->instances[i].instance[j] = 0.0;
	}}

static void featureMean_length(t_featureMean *x, t_floatarg len)
{
	int i, j;
    
	if(len)
	{
        x->x_listOut = (t_atom *)t_resizebytes(x->x_listOut, x->featureLength*sizeof(t_atom), len*sizeof(t_atom));
        
		// free the database memory
		for(i=0; i<x->numFrames; i++)
			t_freebytes(x->instances[i].instance, x->featureLength*sizeof(float));
        
		t_freebytes(x->instances, x->numFrames*sizeof(t_instance));
        
		x->instances = (t_instance *)t_getbytes(x->numFrames*sizeof(t_instance));
        
		x->featureLength = len;
		x->currentFrame = 0;
        
        for(i=0; i<x->featureLength; i++)
	        SETFLOAT(x->x_listOut+i, 0.0);
        
		for(i=0; i<x->numFrames; i++)
			x->instances[i].instance = (float *)t_getbytes(x->featureLength*sizeof(float));
        
		for(i=0; i<x->numFrames; i++)
			for(j=0; j<x->featureLength; j++)
				x->instances[i].instance[j] = 0.0;
	}
}

static void featureMean_print(t_featureMean *x)
{
    post("averaging %i vectors with %i features", x->numFrames, x->featureLength);
}

static void *featureMean_new(t_float numFrames, t_float length, t_float spew)
{
	t_featureMean *x = (t_featureMean *)pd_new(featureMean_class);
	int i, j;

	x->featureList = outlet_new(&x->x_obj, gensym("list"));

	x->featureLength = length;
	x->numFrames = numFrames;
	x->currentFrame = 0;

    x->x_listOut = (t_atom *)t_getbytes(x->featureLength*sizeof(t_atom));
    x->instances = (t_instance *)t_getbytes(x->numFrames*sizeof(t_instance));
    
    for(i=0; i<x->featureLength; i++)
        SETFLOAT(x->x_listOut+i, 0.0);
    
    for(i=0; i<x->numFrames; i++)
        x->instances[i].instance = (float *)t_getbytes(x->featureLength*sizeof(float));
    
    for(i=0; i<x->numFrames; i++)
        for(j=0; j<x->featureLength; j++)
            x->instances[i].instance[j] = 0.0;


	return (void *)x;
}

static void featureMean_free(t_featureMean *x)
{
	int i;      
    
    // free the database memory
	for(i=0; i<x->numFrames; i++)
		t_freebytes(x->instances[i].instance, x->featureLength*sizeof(float));
    
    t_freebytes(x->instances, x->numFrames*sizeof(t_instance));
    
    // free listOut memory
	t_freebytes(x->x_listOut, x->featureLength*sizeof(t_atom));

}

void featureMean_setup(void) {

	featureMean_class = class_new(gensym("featureMean"),
		(t_newmethod)featureMean_new,
		(t_method)featureMean_free,
		sizeof(t_featureMean),
		CLASS_DEFAULT,
		A_DEFFLOAT,
		A_DEFFLOAT,
		A_DEFFLOAT,
		0
	);

	class_addlist(featureMean_class, featureMean_accum);
    class_addbang(featureMean_class, featureMean_bang);

	class_addmethod(
		featureMean_class,
        (t_method)featureMean_accum,
		gensym("accum"),
        A_GIMME,
		0
	);

	class_addmethod(
		featureMean_class,
        (t_method)featureMean_clear,
		gensym("clear"),
		0
	);

	class_addmethod(
		featureMean_class,
        (t_method)featureMean_numFrames,
		gensym("num_frames"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		featureMean_class,
        (t_method)featureMean_length,
		gensym("length"),
		A_DEFFLOAT,
		0
	);

}

