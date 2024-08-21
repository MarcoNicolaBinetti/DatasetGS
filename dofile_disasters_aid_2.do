


** import data
import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full.csv", clear


* gen helpful vars
encode iso3c, generate(ID)

g 			dummy_war_terror=0
replace 	dummy_war_terror=1 if year>2001
label var	dummy_war_terror "War terror"

* label vars
** main IVs
g KOF_pol = kofpogi_lag_1
label var 	KOF_pol		 	"KOF pol. glob."
g KOF_cu = 	kofcugi_lag_1
label var 	KOF_cu 			"KOF cu. glob."

g ln_milper = ln(1+mil_per_lag_1)
label var 	ln_milper		"Mil. size"
g ln_milexp = ln(1+mil_exp_usd_lag_1)
label var 	ln_milexp		"Mil. exp"

g NR = 		nat_rents_lag_1
label var 	NR			 	"Nat. rents"
g Oil = 	oil_rents_lag_1
label var 	Oil			 	"Oil rents"

** controls

label var ln_trade_lag_1		 	"Trade"
label var inflation_lag_1		 	"Inflation"
label var inf_mort_rate_lag_1	 	"Inf mort."
label var best_fat_lag_1 			"Conf. intensity"
label var liberal_demo_lag_1 		"Democracy"
label var colony 					"Colony"
label var rpe_agri_lag_1 			"RPE"
label var regime_corruption_lag_1 	"Corruption"
label var military_centr_lag_1 		"Mil. cen."
label var ln_pop_tot_lag_1 			"Pop."
label var fdi_lag_1 				"FDI"
label var ln_gdp_lag_1 				"GDP (ln)"
label var count_ho_lag_1 			"H.O."
label var dis_death 				"Disaster fat."
label var rugged 					"Rugged"
label var desert 					"Desert"
label var tropical 					"Tropical"




*** set variables
** set controls
global Need				inf_mort_rate_lag_1  best_fat_lag_1 dis_death
global Eco_size			ln_trade_lag_1 ln_gdp_lag_1 ln_pop_tot_lag_1  fdi_lag_1
global Merit			inflation_lag_1 rpe_agri_lag_1 regime_corruption_lag_1
global Regime_type		liberal_demo_lag_1 military_centr_lag_1 colony
global Geography		rugged desert tropical
global Additional		i.dummy_war_terror count_ho_lag_1 

global Reduced			dis_death ln_gdp_lag_1 regime_corruption_lag_1 liberal_demo_lag_1

** set main set of controls
global main_cntrls $Need $Eco_size $Merit $Regime_type $Geography

** set mian IVS
global Main_IV 			KOF_pol ln_milper 	Oil 

** alt trade
global Main_IV_atr 		KOF_cu 	ln_milper 	Oil
** alt ME
global Main_IV_ame 		KOF_pol ln_milexp 	Oil 
** alt NR
global Main_IV_anr 		KOF_pol ln_milper	NR
** alt All
global Main_IV_all 		KOF_cu 	ln_milexp	NR

*** set specif
global Spec baseoutcome(4) vce(cluster ID)


*******************************************
************  Main Models  ****************
*******************************************

qui mlogit globsol $Main_IV $main_cntrls	if year<2014, $Spec
estimates store  Model_main


*******************************************
*******************************************
*******************************************
** alt Glob
qui mlogit 	globsol $Main_IV_atr $main_cntrls  if year<2014,$Spec
estimates 	store  	Model_alt_Glob
** alt ME
qui mlogit 	globsol $Main_IV_ame $main_cntrls  if year<2014, $Spec
estimates 	store  	Model_alt_ME
** alt NR
qui mlogit 	globsol $Main_IV_anr $main_cntrls  if year<2014, $Spec
estimates 	store  	Model_alt_NR
** alt all
qui mlogit 	globsol $Main_IV_all $main_cntrls  if year<2014, $Spec
estimates 	store  	Model_alt_all
** no limitation
qui mlogit 	globsol $Main_IV $main_cntrls , $Spec
estimates 	store  	Model_no_lim
** additional controls
qui mlogit 	globsol $Main_IV $main_cntrls $Additional  if year<2014, $Spec
estimates 	store  	Model_add_ctr
** reduced
qui mlogit 	globsol $Main_IV $Reduced  if year<2014, $Spec
estimates 	store  	Model_Red

*******************************************
*******************************************
*******************************************
* set layout
global layout scheme(plotplain)  recast(line)  ciopt(color(black%20)) recastci(rarea)

**** images - main model
estimates restore  Model_main

** corr matrix
correlate   $Main_IV $main_cntrls  if e(sample)
matrix corrmatrix = r(C)
heatplot corrmatrix, label ///
xlab(, angle(45)) ///
graphregion(fcolor(white)) ///
colors(hcl diverging ,gscale) ///
values(format(%4.2f)) legend(off) cuts(-1(`=2/15')1) scheme(plotplain) name(corr_matrix, replace)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\Corr_matrix.png", as(png) replace	


/*
** histo distr
sum KOF_pol if e(sample),d
histogram KOF_pol if e(sample),  frequency  scheme(plotplain) saving(histKOF.gph, replace)  xline(59) xline(83) 
sum ln_milper if e(sample),d
histogram ln_milper if e(sample),  frequency  scheme(plotplain) saving(histME.gph, replace)  xline(11) xline(13) 
sum NR if e(sample),d
histogram NR if e(sample),  frequency  scheme(plotplain) saving(histNR.gph, replace)  xline(1.2) xline(8) 
*/

** distribution vars
sum KOF_pol if e(sample),d
vioplot KOF_pol if e(sample), over(globsol)  scheme(plotplain) title("Distribution of KOF across GlobSol") name(Vio1, replace) yline(61) yline(82) ytitle("KOF index") xtitle("GlobSol values")
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\vio_plots1.png", as(png) replace	

sum ln_milper if e(sample),d
vioplot ln_milper if e(sample), over(globsol)  scheme(plotplain) title("Distribution of Mil. per. across GlobSol") name(Vio2, replace) yline(11) yline(13) ytitle("Mil. per") xtitle("GlobSol values")
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\vio_plots2.png", as(png) replace	

sum Oil if e(sample),d
vioplot Oil if e(sample), over(globsol)  scheme(plotplain) title("Distribution of Oil across GlobSol") name(Vio3, replace) yline(1.2) yline(8) ytitle("Oil rents.") xtitle("GlobSol values")
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\vio_plots3.png", as(png) replace	


*******************************************
************** Main model *****************
*******************************************
estimates restore  Model_main
sum KOF_pol  ln_milper  Oil  if e(sample)


margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1.png", as(png) name("g1") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2.png", as(png) name("g2") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3.png", as(png) name("g3") replace	

graph drop p1 p2 p3 p4

*******************************************
************** Alt global *****************
*******************************************

estimates restore  Model_alt_Glob
sum  KOF_cu ln_milper NR if e(sample)

margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1b, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1b.png", as(png) name("g1b") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2b, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2b.png", as(png) name("g2b") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3b, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3b.png", as(png) name("g3b") replace	

graph drop p1 p2 p3 p4

*******************************************
************** Alt Mil *****************
*******************************************

estimates restore  Model_alt_ME
sum  KOF_pol ln_milexp NR if e(sample)

margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1c, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1c.png", as(png) name("g1c") replace	

margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2c, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2c.png", as(png) name("g2c") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3c, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3c.png", as(png) name("g3c") replace	

graph drop p1 p2 p3 p4

*******************************************
************    Alt NR    *****************
*******************************************

estimates restore  Model_alt_NR
sum  KOF_pol ln_milper NR if e(sample)

margins , at(KOF_pol = (30(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_pol = (30(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(KOF_pol = (30(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace)$layout
margins , at(KOF_pol = (30(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1d, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1d.png", as(png) name("g1d") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2d, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2d.png", as(png) name("g2d") replace	

margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3d, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3d.png", as(png) name("g3d") replace	

graph drop p1 p2 p3 p4



*******************************************
************    Alt all    *****************
*******************************************

estimates restore  Model_alt_all

margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1e, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1e.png", as(png) name("g1e") replace	

margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2e, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2e.png", as(png) name("g2e") replace	

margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3e, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3e.png", as(png) name("g3e") replace	

graph drop p1 p2 p3 p4



*******************************************
************    No lim    *****************
*******************************************

estimates restore  Model_no_lim

margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1f, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1f.png", as(png) name("g1f") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2f, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2f.png", as(png) name("g2f") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3f, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3f.png", as(png) name("g3f") replace	

graph drop p1 p2 p3 p4




*******************************************
************    add ctrl  *****************
*******************************************

estimates restore  Model_add_ctr

margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1g, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1g.png", as(png) name("g1g") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2g, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2g.png", as(png) name("g2g") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3g, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3g.png", as(png) name("g3g") replace	

graph drop p1 p2 p3 p4



*******************************************
************    reduced ctrls  ************
*******************************************

estimates restore  Model_Red

margins , at(KOF_pol = (0(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(KOF_pol = (0(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(KOF_pol = (0(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace)$layout
margins , at(KOF_pol = (0(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g1h, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3h.png", as(png) name("g1h") replace	

margins , at(ln_milper = (8(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(ln_milper = (8(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(ln_milper = (8(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(ln_milper = (8(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g2h, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2h.png", as(png) name("g2h") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout
graph combine p1 p2 p3 p4, ycommon name(g3h, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3h.png", as(png) name("g3h") replace	

graph drop p1 p2 p3 p4










qui mlogit	globsol $Main_IV $Need $Merit	if year<2014, $Spec
estimates 	store  	Model_NeedMerit
qui mlogit 	globsol $Main_IV $Eco_size		if year<2014, $Spec
estimates	store  	Model_EcoSize
qui mlogit 	globsol $Main_IV $Regime_type	if year<2014, $Spec
estimates	store  	Model_RegType
qui mlogit	globsol $Main_IV $Reduced		if year<2014, $Spec
estimates 	store  	Model_Red




