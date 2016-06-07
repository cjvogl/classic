import numpy as np
import glob
from scipy import interpolate
from clawpack.clawutil.data import ClawData
from clawpack.visclaw.data import ClawPlotData
from clawpack.pyclaw import io, Solution
from pylab import figure, plot, show


ABL_DEPTH = 0.0

def compute_error(outdir='./_output'):

    files = glob.glob(('%s/fort.q*' % outdir))
    num_frames = len(files)

    clawdata = ClawData()
    clawdata.read(('%s/claw.data' % outdir), force=True)

    outpath = ('%s/' % outdir)
    outpath1d = ('%s1d/' % outdir)

    times = np.zeros(num_frames)
    L2p = np.zeros(num_frames)
    LIp = np.zeros(num_frames)

    sol = Solution()
    io.ascii.read(sol,0,outpath)
    x = sol.state.grid.x.centers
    x = np.ma.masked_where(x > clawdata.upper[0] - ABL_DEPTH, x)
    num_x = np.ma.count(x)
    y = sol.state.grid.y.centers
    num_y = np.size(y)
    rvals = np.zeros((num_x,num_y))
    for i in np.arange(num_x):
        for j in np.arange(num_y):
            rvals[i][j] = np.sqrt(x[i]**2 + y[j]**2)
    rvals = rvals.flatten('F');

    sol = Solution()
    io.ascii.read(sol,0,outpath1d)
    rvals1d = sol.state.grid.x.centers

    for n in np.arange(num_frames):
        print ('Generating errors for frame %d' % n)

        sol = Solution()
        io.ascii.read(sol,n,outpath1d)
        q1d = sol.state.q
        #q1di = interpolate.pchip(rvals1d,q1d[0,:])
        q1di = interpolate.interp1d(rvals1d,q1d[0,:])

        sol = Solution()
        io.ascii.read(sol,n,outpath)
        q = sol.state.q
        t = sol.state.t
        qflat = q[0,:,:].flatten(order='F')
        diff = qflat - q1di(rvals)
        q_new = np.zeros((4,num_x,num_y))
        q_new[0,:,:] = q[0,:,:]
        q_new[1,:,:] = q[1,:,:]
        q_new[2,:,:] = q[2,:,:]
        q_new[3,:,:] = diff.reshape((num_x,num_y),order='F')
        sol.state.q = q_new
        sol.write(n,path=outpath)

        times[n] = t
        L2p[n] = np.sqrt(np.sum(diff**2)/num_x/num_y)
        LIp[n] = max(abs(diff))

    figure(1)
    plot(times,L2p)
    figure(2)
    plot(times,LIp)

    output = np.vstack((times,L2p,LIp)).T
    np.savetxt(('%serrors.txt' % outpath),output,fmt='%12.3e')

if __name__=='__main__':
    import sys
    args = sys.argv[1:]
    compute_error(*args)
