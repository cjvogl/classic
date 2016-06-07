# NOTE THAT THIS IS CALLED BY setrun1d and setrun2d and only contains common parameters

def setCommonParameters(clawdata,probdata):

    # --------------------
    # Acoustic Parameters:
    #---------------------

    probdata.add_param('rho',     1.,  'density of medium')
    probdata.add_param('bulk',    4.,  'bulk modulus')

    # -------------
    # Output times:
    #--------------

    # Specify at what times the results should be written to fort.q files.
    # Note that the time integration stops after the final output time.

    clawdata.output_style = 1 # CHANGE IN THIS REQUIRES CHANGE IN setrun1d

    if clawdata.output_style==1:
        # Output ntimes frames at equally spaced times up to tfinal:
        # Can specify num_output_times = 0 for no output
        clawdata.num_output_times = 40
        clawdata.tfinal = 2.0
        clawdata.output_t0 = True  # output at initial (or restart) time?

    elif clawdata.output_style == 2:
        # Specify a list or numpy array of output times:
        # Include t0 if you want output at the initial time.
        clawdata.output_times =  [0., 0.1]

    elif clawdata.output_style == 3:
        # Output every step_interval timesteps over total_steps timesteps:
        clawdata.output_step_interval = 2
        clawdata.total_steps = 4
        clawdata.output_t0 = True  # output at initial (or restart) time?

    clawdata.output_format = 'ascii'       # 'ascii', 'binary', 'netcdf'
