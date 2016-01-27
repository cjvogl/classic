from numpy import zeros, linspace, exp, sum, sqrt, max, abs
from pylab import figure, plot

def compute_error(output_num):
    output_file = open('./_output/fort.t%s' % output_num.zfill(4))
    line = output_file.readline() #time
    time = float(line.split()[0])
    output_file.close()

    output_file = open('./_output/fort.q%s' % output_num.zfill(4))
    line = output_file.readline() #grid number
    line = output_file.readline() #AMR_level
    line = output_file.readline() #mx
    num_points = int(line.split()[0])
    line = output_file.readline() #xlow
    x_beg = float(line.split()[0])
    line = output_file.readline() #dx
    dx = float(line.split()[0])
    line = output_file.readline() #\n

    p = zeros(num_points)
    x = zeros(num_points)
    for ind in range(num_points):
        x[ind] = x_beg + (ind + 0.5)*dx
        line = output_file.readline()
        p[ind] = float(line.split()[0])
    output_file.close

    u = sqrt(0.002202256/1000.0)
    exact = 0.5*1.0e-5*exp(-(((x-u*time)-0.1162)/4.5e-4)**2)
    diff = p - exact
    figure(1)
    plot(x,p)
    plot(x,exact)
    figure(2)
    plot(x,diff)
    L2 = sqrt(dx*sum(diff**2))
    LI = max(abs(diff))
    print('L2 error at time %4.1f: %e' % (time, L2))
    print('LI error at time %4.1f: %e' % (time, LI))


if __name__=='__main__':
    import sys
    args = sys.argv[1:]   # any command line arguments
    compute_error(*args)
