


** import data
import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full.csv", clear
*import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full_100.csv", clear

tab globsol if year<2014

* label vars
label var globsol 			"GlobSol"

** set main independent variables
{
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
}

** gen and label controls
{
encode iso3c, generate(ID)


g ln_inf_mort_rate_lag_1= ln(inf_mort_rate_lag_1)
g ln_dis_death=ln(dis_death)


g ln_inflation_lag_1=ln(inflation_lag_1)
g ln_pop_tot_lag_1= ln(pop_tot_lag_1)

g ln_fdi_lag_1= ln(fdi_lag_1)
g ln_trade_lag_1=ln(trade_lag_1)

g ln_gdp_pc_lag_1 = ln(gdp_per_cap_ppp_lag_1)


g 			dummy_war_terror=0
replace 	dummy_war_terror=1 if year>2001

label var ln_inf_mort_rate_lag_1	"Inf. mort."
label var ln_dis_death 				"Dis. fat."

label var ln_inflation_lag_1		"Inflation"
label var ln_pop_tot_lag_1 			"Pop."

label var ln_trade_lag_1		 	"Trade"
label var ln_fdi_lag_1 				"FDI"

label var ln_gdp_pc_lag_1			"GDP p.c."
label var rpe_agri_lag_1 			"RPE"

label var liberal_demo_lag_1 		"Dem. index"
label var colony 					"Colony"

label var count_ho_lag_1 			"H.O."
label var rugged 					"Rugged"
}

* old vars
{
g ln_best_fat_lag_1=ln(best_fat_lag_1)
	
	
label var desert 					"Desert"
label var tropical 					"Tropical"
label var dummy_war_terror			"War on terror"
label var best_fat_lag_1 			"Conf. fat."
label var regime_corruption_lag_1 	"Corr."
label var civil_soc_lag_1 			"Civil. soc."
label var military_centr_lag_1 		"Mil. cen."
}



*** set globals
** set controls
{
global Need				ln_inf_mort_rate_lag_1  ln_dis_death 				 
global Merit			ln_inflation_lag_1 		ln_pop_tot_lag_1
global Eco_size			ln_trade_lag_1 			ln_fdi_lag_1
global React			rpe_agri_lag_1			ln_gdp_pc_lag_1 			
global Regime_type		liberal_demo_lag_1 		colony
global Logistic			rugged  				count_ho_lag_1				

  

global Reduced			ln_inf_mort_rate_lag_1 ln_trade_lag_1 ln_pop_tot_lag_1 ln_gdp_per_cap_ppp_lag_1 liberal_demo_lag_1 rugged 

** set main set of controls
global main_cntrls $Need  $Merit $Eco_size $React $Regime_type $Logistic
}

** set mian IVS
{
global Main_IV 			KOF_pol ln_milper 	Oil 
** alt trade
global Main_IV_atr 		KOF_cu 	ln_milper 	Oil
** alt ME
global Main_IV_ame 		KOF_pol ln_milexp 	Oil 
** alt NR
global Main_IV_anr 		KOF_pol ln_milper	NR
** alt All
global Main_IV_all 		KOF_cu 	ln_milexp	NR
}

** set specif
{
	global Spec baseoutcome(4) vce(cluster ID)
}

** set addstat
{
global Add_stat  Wald chi2(57), 				e(chi2), ///
Prob > chi2, 									e(p), ///
Pseudo R2, 										e(r2_p), ///
Log pseudolikelihood, 							e(ll)
}

** set layout
{
global layout scheme(plotplain)  recast(line)  ciopt(color(black%20)) recastci(rarea)
}

*******************************************
************  Main Model  ****************
*******************************************
mlogit globsol $Main_IV $main_cntrls if year<2014, $Spec
estimates store  Model_main
fitstat



*******************************************
*************** Alt models ****************
*******************************************
{
** alt Glob
qui mlogit 	globsol $Main_IV_atr $main_cntrls  			if year<2014,	$Spec
estimates 	store  	Model_alt_Glob
fitstat

** alt ME
qui mlogit 	globsol $Main_IV_ame $main_cntrls  			if year<2014, 	$Spec
estimates 	store  	Model_alt_ME
fitstat

** alt NR
qui mlogit 	globsol $Main_IV_anr $main_cntrls  			if year<2014, 	$Spec
estimates 	store  	Model_alt_NR
fitstat

** alt all
qui mlogit 	globsol $Main_IV_all $main_cntrls  			if year<2014, 	$Spec
estimates 	store  	Model_alt_all
fitstat

** no limitation
qui mlogit 	globsol $Main_IV $main_cntrls 							,	$Spec
estimates 	store  	Model_no_lim
fitstat

}
*******************************************
*******************************************
*******************************************

**** images - main model
estimates restore  Model_main

** corr matrix
{
correlate   $Main_IV $main_cntrls  if e(sample)
matrix corrmatrix = r(C)
heatplot corrmatrix, label ///
xlab(, angle(45)) ///
graphregion(fcolor(white)) ///
colors(hcl diverging ,gscale) ///
values(format(%4.2f)) legend(off) cuts(-1(`=2/15')1) scheme(plotplain) name(corr_matrix, replace)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\Corr_matrix.png", as(png) replace	
}


** distribution main vars 
{
vioplot KOF_pol 	if e(sample), 	over(globsol) ///
									scheme(plotplain) ///
									title("KOF index") ///
									name(Vio1, replace) ///
									ytitle("") ///
									xtitle("GlobSol values")
							  
vioplot ln_milper 	if e(sample), 	over(globsol) ///
									scheme(plotplain) ///
									title("Mil. per.") ///
									name(Vio2, replace) ///
									ytitle("") ///
									xtitle("GlobSol values") 

vioplot Oil 		if e(sample), 	over(globsol) /// 
									scheme(plotplain) ///
									title("Oil rents") ///
									name(Vio3, replace) ///
									ytitle("") ///
									xtitle("GlobSol values")

									
									
									
graph combine Vio1 Vio2 Vio3, col(3) title("Distribution of main indipendent variables") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphA.png", as(png) name("combined") replace

graph drop  Vio1 Vio2 Vio3
}


** distribution covariates 1 
{
* Create individual violin plots for each variable
vioplot ln_inf_mort_rate_lag_1  if e(sample), 	over(globsol) ///
												name(Vio1,replace) ///
												title("Inf. mort.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 

vioplot ln_dis_death 			if e(sample), 	over(globsol) ///
												name(Vio2,replace) ///
												title("Dis. fat.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot ln_pop_tot_lag_1  		if e(sample), 	over(globsol) ///
												name(Vio3,replace) ///
												title("Pop.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
	
vioplot ln_inflation_lag_1  	if e(sample), 	over(globsol) ///
												name(Vio4,replace) ///
												title("Inflation") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 

vioplot ln_trade_lag_1  		if e(sample), 	over(globsol) ///
												name(Vio5,replace) ///
												title("Trade") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot ln_fdi_lag_1  			if e(sample), 	over(globsol) ///
												name(Vio6,replace) ///
												title("FDI")  ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
			
* Combine the plots into a single graph
graph combine Vio1 Vio2 Vio3 Vio4 Vio5 Vio6, col(3) title("Distribution of covariates, pt. 1") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphB.png", as(png) name("combined") replace

graph drop  Vio1 Vio2 Vio3 Vio4 Vio5 Vio6
}
****

** distribution covariates 2
{
* Create individual violin plots for each variable
vioplot rpe_agri_lag_1 			 if e(sample), 	over(globsol) ///
												name(Vio1,replace) ///
												title("RPE") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 

vioplot ln_gdp_pc_lag_1			if e(sample), 	over(globsol) ///
												name(Vio2,replace) ///
												title("GDP") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot liberal_demo_lag_1  	if e(sample), 	over(globsol) ///
												name(Vio3,replace) ///
												title("Dem. index.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
	
g colony_label =""
replace colony_label= "Col.=1" if colony==1
replace colony_label= "Col.=0" if colony==0
	

g gs_label =""
replace gs_label= "GS.=1" if globsol==1
replace gs_label= "GS.=2" if globsol==2
replace gs_label= "GS.=3" if globsol==3
replace gs_label= "GS.=4" if globsol==4

	
graph bar (percent) 			if e(sample), 	over(colony_label) ///
												over(gs_label) ///
												title("Colony") ///
												ytitle("Percentage") ///
												horizontal ///
												scheme(plotplain) ///
												name(barplot1, replace)

vioplot rugged			  		if e(sample), 	over(globsol) ///
												name(Vio5,replace) ///
												title("Rugged") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot count_ho_lag_1  		if e(sample), 	over(globsol) ///
												name(Vio6,replace) ///
												title("H.O.")  ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
			
* Combine the plots into a single graph
graph combine Vio1 Vio2 Vio3 barplot1 Vio5 Vio6, col(3) title("Distribution of covariates, pt. 2") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphC.png", as(png) name("combined") replace
drop gs_label colony_label
graph drop  Vio1 Vio2 Vio3 barplot1 Vio5 Vio6
}
****

  								

*******************************************
************** Main model *****************
*******************************************

** table
{
estimates restore  Model_main

outreg2 using Tab1.doc, ctitle(Model 1, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV $main_cntrls  ) ///
keep 		(   $Main_IV $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure
{
	
estimates restore  Model_main
sum KOF_pol  ln_milper  Oil  if e(sample)


margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout ytitle(pr. Symbolic Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1.png", as(png) name("g1") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2.png", as(png) name("g2") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3.png", as(png) name("g3") replace	

graph drop p1 p2 p3 p4

}

*******************************************
************** Alt global *****************
*******************************************

** table
{
estimates restore  Model_alt_Glob

outreg2 using Tab1A.doc, ctitle(Model 2, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV_atr $main_cntrls  ) ///
keep 		(   $Main_IV_atr $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure
{
estimates restore  Model_alt_Glob
sum  KOF_cu ln_milper NR if e(sample)

margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1b, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1b.png", as(png) name("g1b") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2b, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2b.png", as(png) name("g2b") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3b, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3b.png", as(png) name("g3b") replace	

graph drop p1 p2 p3 p4
}
*******************************************
************** Alt Mil *****************
*******************************************

** table
{
estimates restore  Model_alt_ME

outreg2 using Tab2A.doc, ctitle(Model 3, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV_ame $main_cntrls  ) ///
keep 		(   $Main_IV_ame $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure
{
estimates restore  Model_alt_ME
sum  KOF_pol ln_milexp NR if e(sample)

margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout ytitle(pr. Symbolic Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1c, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1c.png", as(png) name("g1c") replace	

margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2c, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2c.png", as(png) name("g2c") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3c, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3c.png", as(png) name("g3c") replace	

graph drop p1 p2 p3 p4
}
*******************************************
************    Alt NR    *****************
*******************************************

** table
{
estimates restore  Model_alt_NR

outreg2 using Tab3A.doc, ctitle(Model 4, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV_anr $main_cntrls  ) ///
keep 		(   $Main_IV_anr $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}
** plots
{
estimates restore  Model_alt_NR
sum  KOF_pol ln_milper NR if e(sample)

margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout  ytitle(pr. Symbolic Solidarity)
margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1d, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1d.png", as(png) name("g1d") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2d, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2d.png", as(png) name("g2d") replace	

margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3d, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3d.png", as(png) name("g3d") replace	

graph drop p1 p2 p3 p4

}

*******************************************
************    Alt all    *****************
*******************************************

** table
{
estimates restore  Model_alt_all

outreg2 using Tab4A.doc, ctitle(Model 5, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV_all $main_cntrls  ) ///
keep 		(   $Main_IV_all $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure

estimates restore  Model_alt_all

margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_cu = (0(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1e, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1e.png", as(png) name("g1e") replace	

margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milexp = (0(0.5) 30)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2e, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2e.png", as(png) name("g2e") replace	

margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(NR = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3e, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3e.png", as(png) name("g3e") replace	

graph drop p1 p2 p3 p4



*******************************************
************    No lim    *****************
*******************************************
{
estimates restore  Model_main

outreg2 using Tab5A.doc, ctitle(Model 6, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV $main_cntrls  ) ///
keep 		(   $Main_IV $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure
{
estimates restore  Model_no_lim

margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout  ytitle(pr. Symbolic Solidarity)
margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_pol = (28(2) 100))    atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1f, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1f.png", as(png) name("g1f") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2f, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2f.png", as(png) name("g2f") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3f, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3f.png", as(png) name("g3f") replace	

graph drop p1 p2 p3 p4

}


***

** import data
*import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full.csv", clear
import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full_100.csv", clear

tab globsol if year<2014

* label vars
label var globsol 			"GlobSol"

** set main independent variables
{
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
}

** gen and label controls
{
encode iso3c, generate(ID)


g ln_inf_mort_rate_lag_1= ln(inf_mort_rate_lag_1)
g ln_dis_death=ln(dis_death)


g ln_inflation_lag_1=ln(inflation_lag_1)
g ln_pop_tot_lag_1= ln(pop_tot_lag_1)

g ln_fdi_lag_1= ln(fdi_lag_1)
g ln_trade_lag_1=ln(trade_lag_1)

g ln_gdp_pc_lag_1 = ln(gdp_per_cap_ppp_lag_1)


g 			dummy_war_terror=0
replace 	dummy_war_terror=1 if year>2001

label var ln_inf_mort_rate_lag_1	"Inf. mort."
label var ln_dis_death 				"Dis. fat."

label var ln_inflation_lag_1		"Inflation"
label var ln_pop_tot_lag_1 			"Pop."

label var ln_trade_lag_1		 	"Trade"
label var ln_fdi_lag_1 				"FDI"

label var ln_gdp_pc_lag_1			"GDP p.c."
label var rpe_agri_lag_1 			"RPE"

label var liberal_demo_lag_1 		"Dem. index"
label var colony 					"Colony"

label var count_ho_lag_1 			"H.O."
label var rugged 					"Rugged"
}

* old vars
{
g ln_best_fat_lag_1=ln(best_fat_lag_1)
	
	
label var desert 					"Desert"
label var tropical 					"Tropical"
label var dummy_war_terror			"War on terror"
label var best_fat_lag_1 			"Conf. fat."
label var regime_corruption_lag_1 	"Corr."
label var civil_soc_lag_1 			"Civil. soc."
label var military_centr_lag_1 		"Mil. cen."
}



*** set globals
** set controls
{
global Need				ln_inf_mort_rate_lag_1  ln_dis_death 				 
global Merit			ln_inflation_lag_1 		ln_pop_tot_lag_1
global Eco_size			ln_trade_lag_1 			ln_fdi_lag_1
global React			rpe_agri_lag_1			ln_gdp_pc_lag_1 			
global Regime_type		liberal_demo_lag_1 		colony
global Logistic			rugged  				count_ho_lag_1				

  

global Reduced			ln_inf_mort_rate_lag_1 ln_trade_lag_1 ln_pop_tot_lag_1 ln_gdp_per_cap_ppp_lag_1 liberal_demo_lag_1 rugged 

** set main set of controls
global main_cntrls $Need  $Merit $Eco_size $React $Regime_type $Logistic
}


** set specif
{
	global Spec baseoutcome(4) vce(cluster ID)
}

** set addstat
{
global Add_stat  Wald chi2(57), 				e(chi2), ///
Prob > chi2, 									e(p), ///
Pseudo R2, 										e(r2_p), ///
Log pseudolikelihood, 							e(ll)
}

** set layout
{
global layout scheme(plotplain)  recast(line)  ciopt(color(black%20)) recastci(rarea)
}

*******************************************
************  Main Model  ****************
*******************************************
mlogit globsol $Main_IV $main_cntrls if year<2014, $Spec
estimates store  Model_main
fitstat


							

*******************************************
************** Main model *****************
*******************************************

** table
{
mlogit globsol $Main_IV $main_cntrls if year<2014, $Spec
estimates store  Model_main
fitstat

outreg2 using Tab6A.doc, ctitle(Model 7, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV $main_cntrls  ) ///
keep 		(   $Main_IV $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure
{
	
estimates restore  Model_main
sum KOF_pol  ln_milper  Oil  if e(sample)


margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout ytitle(pr. Symbolic Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1g, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1g.png", as(png) name("g1g") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2g, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2g.png", as(png) name("g2g") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3g, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3g.png", as(png) name("g3g") replace	

graph drop p1 p2 p3 p4

}

***

** import data
*import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full.csv", clear
import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full_5.csv", clear

tab globsol if year<2014

* label vars
label var globsol 			"GlobSol"

** set main independent variables
{
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
}

** gen and label controls
{
encode iso3c, generate(ID)


g ln_inf_mort_rate_lag_1= ln(inf_mort_rate_lag_1)
g ln_dis_death=ln(dis_death)


g ln_inflation_lag_1=ln(inflation_lag_1)
g ln_pop_tot_lag_1= ln(pop_tot_lag_1)

g ln_fdi_lag_1= ln(fdi_lag_1)
g ln_trade_lag_1=ln(trade_lag_1)

g ln_gdp_pc_lag_1 = ln(gdp_per_cap_ppp_lag_1)


g 			dummy_war_terror=0
replace 	dummy_war_terror=1 if year>2001

label var ln_inf_mort_rate_lag_1	"Inf. mort."
label var ln_dis_death 				"Dis. fat."

label var ln_inflation_lag_1		"Inflation"
label var ln_pop_tot_lag_1 			"Pop."

label var ln_trade_lag_1		 	"Trade"
label var ln_fdi_lag_1 				"FDI"

label var ln_gdp_pc_lag_1			"GDP p.c."
label var rpe_agri_lag_1 			"RPE"

label var liberal_demo_lag_1 		"Dem. index"
label var colony 					"Colony"

label var count_ho_lag_1 			"H.O."
label var rugged 					"Rugged"
}

* old vars
{
g ln_best_fat_lag_1=ln(best_fat_lag_1)
	
	
label var desert 					"Desert"
label var tropical 					"Tropical"
label var dummy_war_terror			"War on terror"
label var best_fat_lag_1 			"Conf. fat."
label var regime_corruption_lag_1 	"Corr."
label var civil_soc_lag_1 			"Civil. soc."
label var military_centr_lag_1 		"Mil. cen."
}



*** set globals
** set controls
{
global Need				ln_inf_mort_rate_lag_1  ln_dis_death 				 
global Merit			ln_inflation_lag_1 		ln_pop_tot_lag_1
global Eco_size			ln_trade_lag_1 			ln_fdi_lag_1
global React			rpe_agri_lag_1			ln_gdp_pc_lag_1 			
global Regime_type		liberal_demo_lag_1 		colony
global Logistic			rugged  				count_ho_lag_1				

  

global Reduced			ln_inf_mort_rate_lag_1 ln_trade_lag_1 ln_pop_tot_lag_1 ln_gdp_per_cap_ppp_lag_1 liberal_demo_lag_1 rugged 

** set main set of controls
global main_cntrls $Need  $Merit $Eco_size $React $Regime_type $Logistic
}


** set specif
{
	global Spec baseoutcome(4) vce(cluster ID)
}

** set addstat
{
global Add_stat  Wald chi2(57), 				e(chi2), ///
Prob > chi2, 									e(p), ///
Pseudo R2, 										e(r2_p), ///
Log pseudolikelihood, 							e(ll)
}

** set layout
{
global layout scheme(plotplain)  recast(line)  ciopt(color(black%20)) recastci(rarea)
}

*******************************************
************  Main Model  ****************
*******************************************
mlogit globsol $Main_IV $main_cntrls if year<2014, $Spec
estimates store  Model_main
fitstat


							

*******************************************
************** Main model *****************
*******************************************

** table
{
mlogit globsol $Main_IV $main_cntrls if year<2014, $Spec
estimates store  Model_main
fitstat

outreg2 using Tab7A.doc, ctitle(Model 8, GlobSol, Multinomial logit) ///
sortvar 	(   $Main_IV $main_cntrls  ) ///
keep 		(   $Main_IV $main_cntrls ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}

** figure
{
	
estimates restore  Model_main
sum KOF_pol  ln_milper  Oil  if e(sample)


margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace)$layout ytitle(pr. Symbolic Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_pol = (28(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1h, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1h.png", as(png) name("g1h") replace	

margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.05) 15)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2h, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2h.png", as(png) name("g2h") replace	

margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3h, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3h.png", as(png) name("g3h") replace	

graph drop p1 p2 p3 p4

}











