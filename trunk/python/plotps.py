from read_sigma import read_header, read_specdata, read_griddata
import spharm
import numpy as np
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt
import sys

class ncepsigma(object):
    def __init__(self,filename):
        nlons,nlats,nlevs,ntrunc = read_header(filename)
        self.nlons = nlons; self.nlats = nlats
        self.ntrunc = ntrunc; self.nlevs = nlevs
        self.filename = filename
        self.sp = spharm.Spharmt(nlons,nlats,6.3712e6,gridtype='gaussian')
        lats,wts = spharm.gaussian_lats_wts(nlats)
        self.lats = lats
        self.lons = (360./nlons)*np.arange(nlons)
    def spectogrd(self,specdata):
        return self.sp.spectogrd(specdata)
    def getuv(self,vrtdata,divdata):
        return self.sp.getuv(vrtdata,divdata)
    def specdata(self):
        vrtspec, divspec,tempspec,zspec,lnpsspec,qspec =\
        read_specdata(self.filename,self.ntrunc,self.nlevs)
        return vrtspec.T,divspec.T,tempspec.T,zspec,lnpsspec,qspec.T

filename = sys.argv[1]

sigfile = ncepsigma(filename)
vrtspec,divspec,tempspec,zspec,lnpsspec,qspec = sigfile.specdata()

lons,lats = np.meshgrid(sigfile.lons,sigfile.lats)
psg = sigfile.spectogrd(lnpsspec)
psg = 10.*np.exp(psg) # hPa
print psg.min(), psg.max(), psg.shape

m = Basemap(projection='npstere',boundinglat=15,lon_0=90,round=True)
x,y = m(lons,lats)
levs = np.arange(850,1050,5).tolist()
levs.remove(1000)
m.contour(x,y,psg,[1000.],linestyles='dotted',linewidths=1,colors='k')
m.contour(x,y,psg,levs,linewidths=1,colors='k')
m.drawparallels(np.arange(0,76,15),latmax=75)
m.drawmeridians(np.arange(0,360,30),labels=[1,1,1,1],latmax=90)
plt.title('ps from %s'%filename,y=1.05)
plt.show()