import uproot as up
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import numpy as np

bmin=0
bwidth=0.1
bmax=3+bwidth
ovariable="PLep"
yaxisname="PLep [GeV]"
accmap_weight="AccWeight_ptheta"
det = "ND280"
outfilename="validation.pdf"
slist = open("syst.list", "r")

class variation:
    def __init__(self, systname, detname, genname):
        self.systname = systname
        self.detname = detname
        self.genname = genname
        # ND280_NEUT_NCasc_FrInelHigh_pi_var.card.root for example
        self.filevar     = f"{self.systname}/{self.detname}_{self.genname}_{self.systname}_var.card.root"
        self.filevarup   = f"{self.systname}/{self.detname}_{self.genname}_{self.systname}_varup.card.root"
        self.filevardown = f"{self.systname}/{self.detname}_{self.genname}_{self.systname}_vardown.card.root"

    def get(self,f, lab, ax, c):
        events = up.open(f)["T2KNOvATruthTree"]
        PLep = events.array(variable)
        Weight = events.array("RWWeight") * events.array(accmap_weight)
        ret = ax.hist(x=PLep, bins=np.arange(bmin, bmax, bwidth), weights=Weight,
                      label=lab, fill=False, color=c, histtype='step')
        plt.subplots_adjust(hspace = .001)
        return ret
    
    def getvar(self, ax):
        return self.get(self.filevar, '1', ax, "red")
    def getvarup(self, ax):
        return self.get(self.filevarup, '1.5', ax, "blue")
    def getvardown(self, ax):
        return self.get(self.filevardown, '0.5', ax, "green")
        
svars=[]
for line in slist.readlines():
    words=line.split()
    if (len(words)==0):
        continue
    gen=words[0]
    if gen[0] == "#":
        continue
    stype=words[1]
    syst=words[2]

    svars.append(variation(syst,det,gen))


with PdfPages(outfilename) as pdf:
    for var in svars:
        print(f"Considering {var.systname}")
        fig, ax = plt.subplots(nrows=2, ncols=1)
        ax[0].grid()
        ax[1].grid()

        nom,   bins, _ = var.getvar    (ax[0])
        vup,   _   , _ = var.getvarup  (ax[0])
        vdown, _   , _ = var.getvardown(ax[0])

        ax[0].set_title(f"{var.systname} on {det}")
        ax[0].legend()
        ax[1].plot(bins[:-1]+0.5*bwidth, vup   / nom, color="blue")
        ax[1].plot(bins[:-1]+0.5*bwidth, vdown / nom, color="green")
        ax[0].set_ylabel("Events")
        ax[1].set_ylabel("Ratio to \"nominal\"")
        ax[1].set_xlabel(yaxisname)
        ax[0].set_xticklabels([])
        ax[0].set_xlim([0,3])
        ax[1].set_xlim([0,3])
        
        pdf.savefig()
        plt.close()
        

    
