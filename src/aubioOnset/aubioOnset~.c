/**
 * adapted for Pure Data by Marius Miron (INESC Porto) after an external by Paul Brossier
 * a puredata wrapper for aubio onset detection functions 
 *
 * Thanks to Johannes M Zmolnig for writing the excellent HOWTO:
 *       http://iem.kug.ac.at/pd/externals-HOWTO/  
 *
 * */

#include "m_pd.h"
#include "aubio.h"
#include "string.h"

char aubioOnset_version[] = "aubioOnset~ version 0.3";

static t_class *aubioOnset_tilde_class;

void aubioOnset_tilde_setup (void);


typedef struct _aubioOnset_tilde
{
    t_object x_obj;
    t_float threshold;
    t_float silence;
    t_int minioi;  
    t_int pos;                    /*frames%dspblocksize */
    t_int bufsize;
    t_int hopsize;
    char* detectionFunction;
    aubio_onset_t *o;
    fvec_t *in;
    fvec_t *out;
    t_outlet *onsetbang;
} t_aubioOnset_tilde;


static t_int *
aubioOnset_tilde_perform (t_int * w)
{
    t_aubioOnset_tilde *x = (t_aubioOnset_tilde *) (w[1]);
    t_sample *in = (t_sample *) (w[2]);
    int n = (int) (w[3]);
    int j;
    for (j = 0; j < n; j++) {
        /* write input to datanew */
        fvec_write_sample (x->in, in[j], 0, x->pos);
        /*time to do something */
        if (x->pos == x->hopsize - 1) {
            /* block loop */
            aubio_onset (x->o, x->in, x->out);
            if (fvec_read_sample (x->out, 0, 0) > 0.) {
                outlet_bang (x->onsetbang);
            }
            /* end of block loop */
            x->pos = -1;              /* so it will be zero next j loop */
        }
        x->pos++;
    }
    return (w + 4);
}

static void
aubioOnset_tilde_dsp (t_aubioOnset_tilde * x, t_signal ** sp)
{
    dsp_add (aubioOnset_tilde_perform, 3, x, sp[0]->s_vec, sp[0]->s_n);
}

static void
aubioOnset_tilde_debug (t_aubioOnset_tilde * x)
{
    post ("aubioOnset~ bufsize:\t%d", x->bufsize);
    post ("aubioOnset~ hopsize:\t%d", x->hopsize);
    post ("aubioOnset~ threshold:\t%f", x->threshold);
    post ("aubioOnset~ silence threshold:\t%f", x->silence);
    post ("aubioOnset~ minioi:\t%d", x->minioi);
    post ("aubioOnset~ audio in:\t%f", x->in->data[0][0]);
    post ("aubioOnset~ onset:\t%f", x->out->data[0][0]);
}

static void *
aubioOnset_tilde_new (t_symbol *s, long argc, t_atom *argv)
{
    t_atom *ap;
    int i, isPow2, argcount=0;
    t_aubioOnset_tilde *x =
    (t_aubioOnset_tilde *) pd_new (aubioOnset_tilde_class);
    
    
    x->threshold = 0.3;
    x->silence = -70;
    x->minioi = 4;
    x->bufsize = 1024;
    x->hopsize = 512;
    x->detectionFunction = "complex";
    
    for (i = 0, ap = argv; i < argc; i++, ap++) 
    {
        if (atom_getintarg(i, argc, argv))
        {
            if (atom_getint(ap)<0)
            {
                post("%ld: silence threshold %ld",i+1,atom_getint(ap));
                x->silence = (atom_getint(ap) < -120) ? -120 : (atom_getint(ap) > 0) ? 0 : atom_getint(ap);
            }
            else 
            {
                if (argcount == 0) {
                    post("%ld: bufsize %ld",i+1,atom_getint(ap));
                    x->bufsize = atom_getint(ap);
                    argcount = argcount + 1;       
                }
                else {
                    post("%ld: hopsize %ld",i+1,atom_getint(ap));
                    x->hopsize = atom_getint(ap);
                }
            }

        }
        else if (atom_getfloatarg(i, argc, argv))
        {
            post("%ld: threshold %.2f",i+1,atom_getfloat(ap));
            x->threshold = (atom_getfloat(ap) < 1e-5) ? 0.1 : (atom_getfloat(ap) > 0.999) ? 0.999 : atom_getfloat(ap);
        }
        else if (atom_getsymbolarg(i, argc, argv))
        {
            post("%ld: onset detection function %s",i+1, atom_getsymbol(ap)->s_name);
            x->detectionFunction = atom_getsymbol(ap)->s_name;
        }
        else post("%ld: unknown argument type", i+1);
    }

    isPow2 = (int)x->bufsize && !( ((int)x->bufsize-1) & (int)x->bufsize );            
    if(!isPow2)
    {
        error("requested buffer size is not a power of 2. default value of 1024 used instead");
        x->bufsize = 1024;
    }
    isPow2 = (int)x->hopsize && !( ((int)x->hopsize-1) & (int)x->hopsize );            
    if(!isPow2)
    {
        error("requested hop size is not a power of 2. default value of 256 used instead");
        x->hopsize = x->bufsize / 4;
    }
    
    
    if (strcmp(x->detectionFunction,"hfc") == 0) x->o=new_aubio_onset(aubio_onset_hfc,x->bufsize, x->hopsize, 1);
    else if (strcmp(x->detectionFunction,"energy") == 0) x->o=new_aubio_onset(aubio_onset_energy,x->bufsize, x->hopsize, 1);
    else if (strcmp(x->detectionFunction,"phase") == 0) x->o=new_aubio_onset(aubio_onset_phase,x->bufsize, x->hopsize, 1);
    else if (strcmp(x->detectionFunction,"complex") == 0) x->o=new_aubio_onset(aubio_onset_complex,x->bufsize, x->hopsize, 1);
    else if (strcmp(x->detectionFunction,"specdiff") == 0) x->o=new_aubio_onset(aubio_onset_specdiff,x->bufsize, x->hopsize, 1);
    else if (strcmp(x->detectionFunction,"kl") == 0) x->o=new_aubio_onset(aubio_onset_kl,x->bufsize, x->hopsize, 1);
    else if (strcmp(x->detectionFunction,"mkl") == 0) x->o=new_aubio_onset(aubio_onset_mkl,x->bufsize, x->hopsize, 1);
    else x->o=new_aubio_onset(aubio_onset_complex,x->bufsize, x->hopsize, 1);    
    
 
    x->in = (fvec_t *) new_fvec (x->hopsize, 1);
    x->out = (fvec_t *) new_fvec (1, 1);
    
    x->onsetbang = outlet_new (&x->x_obj, &s_bang);
    post (aubioOnset_version);    
     
    aubio_onset_set_threshold(x->o,x->threshold); 
    aubio_onset_set_silence(x->o,x->silence);  
    aubio_onset_set_minioi(x->o,x->minioi);  
    
    return (void *) x;
}

static void
aubioOnset_tilde_threshold (t_aubioOnset_tilde * x, t_float f)
{
    x->threshold = (f < 1e-5) ? 0.1 : (f > 10.) ? 10. : f;
    aubio_onset_set_threshold(x->o,f); 
    post ("aubioOnset~ threshold:\t%f", x->threshold);
}

static void
aubioOnset_tilde_silence (t_aubioOnset_tilde * x, t_float s)
{
    x->silence = (s < -120) ? -120 : (s > 0.) ? 0. : s;
    aubio_onset_set_silence(x->o,x->silence); 
    post ("aubioOnset~ silence threshold:\t%f", x->silence);
}

static void
aubioOnset_tilde_minioi (t_aubioOnset_tilde * x, t_float m)
{
    x->minioi = (m < 4) ? 4 : (int)m;
    aubio_onset_set_minioi(x->o,x->minioi); 
    post ("aubioOnset~ minioi:\t%d", x->minioi);
}


void
aubioOnset_tilde_setup (void)
{
    aubioOnset_tilde_class = class_new (gensym ("aubioOnset~"),
                                        (t_newmethod) aubioOnset_tilde_new,
                                           0, sizeof (t_aubioOnset_tilde), CLASS_DEFAULT, 
                                           A_GIMME, 0);
    class_addmethod (aubioOnset_tilde_class,
                     (t_method) aubioOnset_tilde_dsp, gensym ("dsp"), 0);
    class_addmethod (aubioOnset_tilde_class,
                     (t_method) aubioOnset_tilde_debug, gensym ("debug"), 0);
    class_addmethod (aubioOnset_tilde_class,
                     (t_method) aubioOnset_tilde_threshold, gensym ("threshold"), A_DEFFLOAT, 0);
    class_addmethod (aubioOnset_tilde_class,
                     (t_method) aubioOnset_tilde_silence, gensym ("silence"), A_DEFFLOAT, 0);
    class_addmethod (aubioOnset_tilde_class,
                     (t_method) aubioOnset_tilde_minioi, gensym ("minioi"), A_DEFFLOAT, 0);
    CLASS_MAINSIGNALIN (aubioOnset_tilde_class, t_aubioOnset_tilde, threshold);
}
