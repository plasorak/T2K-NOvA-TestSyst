# T2K-NOvA XSec validation tool

These small scripts can be used to check what the impact of systematics on ND280 and NOVAND are.

## Preamble

To use, you need to setup the proper container and create NEUT and GENIE flat trees as shown [here](https://gist.github.com/plasorak/6674b6d94cff8a1cc647017bc359d2fb) (either for the ND280 or for NOVAND).

## Reweighting

Next to reweight these files quickly, you can create a systematic list file as in the syst.list in this repo and run:
```bash
./ProcessAllSysts.sh syst.list Detector NEUT_file.root GENIE_file.root
```
where `Detector` is either `ND280` of `NOVAND`, and the `NEUT_file.root` and `GENIE_file.root` are the file you created in the preamble.

## Plotting

To plot, you need to have `python3` (fstrings...), `uproot` ([the old one](https://github.com/scikit-hep/uproot)), `matplotlib`, and `numpy`.
`uproot` depends on the all rest, so you can just do:
```bash
pip3 install uproot
```

Then
```bash
python3 PlotRatio.py
```

All the arguements are in the begining of the scripts, and hopefully it's not too complicated to follow:
```python
bmin=0 # ----------------------------- lower bound for plot
bwidth=0.1 # ------------------------- binwidth
bmax=3+bwidth # ---------------------- 3 is the max of theplot
ovariable="PLep" # ------------------- the variable in the tree you want to plot 
yaxisname="PLep [GeV]" # ------------- the y axis name
accmap_weight="AccWeight_ptheta" # --- the acceptance map you want to use
det = "ND280" # ---------------------- or NOVAND
outfilename="validation.pdf" # ------- file name (must be pdf)
slist = open("syst.list", "r") # ----- syst.list file
```
