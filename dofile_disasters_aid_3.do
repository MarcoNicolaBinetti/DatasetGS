


** import data
import delimited "C:/Users/marco/Nextcloud/Global Solidarity/Compiled/df_full.csv", clear
*import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full_100.csv", clear
*import delimited "C:/Users/marco/Nextcloud/Global Solidarity/Compiled/df_full_5k_500d.csv", clear

tab globsol if year<2014

* label vars
label var globsol 			"GlobSol"

** set main independent variables
{
** main IVs
g KOF_pol = kofpogi_lag_1
label var 	KOF_pol		 	"KOF pol."
g KOF_cu = 	kofcugi_lag_1
label var 	KOF_cu 			"KOF cul."

g ln_milper = ln(mil_per_lag_1)
label var 	ln_milper		"Mil. size"
g ln_milexp = ln(mil_exp_usd_lag_1)
label var 	ln_milexp		"Mil. exp"

g NR = 		nat_rents_lag_1
label var 	NR			 	"Nat. rents"
g strat = 	oil_rents_lag_1+minerals_rents_lag_1+gas_rents_lag_1
label var 	strat			 	"Strat. rents"
g Oil 	= 	oil_rents_lag_1
label var 	Oil			 	"Oil rents"

g ln_dis_death=ln(dis_death)

label var ln_dis_death 				"Dis. fat."

}

** gen and label controls
{
encode iso3c, generate(ID)

replace inf_mort_rate_lag_1	= 	ln(inf_mort_rate_lag_1)
replace inflation_lag_1			=	ln(2.4+inflation_lag_1)

*g ln_fdi_lag_1				= 	fdi_lag_1
*g ln_trade_lag_1			=	trade_lag_1

g ln_pop_tot_lag_1			=	ln(pop_tot_lag_1)
g ln_gdp_pc_lag_1			= 	ln(gdp_per_cap_ppp_lag_1)

g ongoing_conf=0
replace ongoing_conf=1 if best_fat_lag_1>0	

g v2regdur_sq=v2regdur*v2regdur
g v2regdur_cu=v2regdur*v2regdur*v2regdur


label var inf_mort_rate_lag_1		"Inf. mort."
label var ongoing_conf				"Conflict"

label var ln_pop_tot_lag_1 			"Pop."
label var age_dep_ratio_lag_1		"Age dep."

label var inflation_lag_1			"Inflation"
label var autonomy_lag_1			"Autonomy"

label var trade_lag_1		 		"Trade"
label var fdi_lag_1 				"FDI"

label var ln_gdp_pc_lag_1			"GDP p.c."
label var rpe_agri_lag_1 			"RPE"

label var liberal_demo_lag_1 		"Dem. index"
label var military_centr_lag_1		"Mil. cen."


label var colony 					"Colony"
label var v2regdur					"Reg. dur."
label var v2regdur_sq				"Reg. dur. (sq)"
label var v2regdur_cu				"Reg. dur. (cu)"

label var count_ho_lag_1 			"H.O."
label var ns_donors_ratio_lag_1		"Donors. ratio"

label var rugged 					"Rugged"
label var tropical 					"Tropical"
}

* old vars
{
g ln_best_fat_lag_1=ln(1+best_fat_lag_1)
g 			dummy_war_terror=0
replace 	dummy_war_terror=1 if year>2001
	

	
g ln_GDP=ln(gdp_lag_1)	
	
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
	
global Need				inf_mort_rate_lag_1  	ongoing_conf		
global Demo	 			ln_pop_tot_lag_1		age_dep_ratio_lag_1
global Merit			inflation_lag_1 		autonomy_lag_1
global Eco_size			trade_lag_1 			fdi_lag_1
global React			rpe_agri_lag_1			ln_gdp_pc_lag_1 			
global Regime_type		liberal_demo_lag_1 		military_centr_lag_1
global Time				colony					v2regdur v2regdur_sq v2regdur_cu
global Logistic			ns_donors_ratio_lag_1 	count_ho_lag_1		
global Geo				rugged					tropical

  
** set main set of controls
global main_cntrls $Need $Demo  $Merit $Eco_size $React $Regime_type $Logistic $Time $Geo

}

** set mian IVS
{
global Main_IV 			ln_dis_death	KOF_cu  	ln_milper 	strat 
** alt trade
global Main_IV_atr 		ln_dis_death	KOF_pol 	ln_milper 	strat 
** alt ME
global Main_IV_ame 		ln_dis_death	KOF_cu  	ln_milexp 	strat 
** alt NR
global Main_IV_anr 		ln_dis_death	KOF_cu  	ln_milper	NR 	  
** alt All
global Main_IV_all 		ln_dis_death	KOF_pol 	ln_milexp	NR 	  
}

** set specif
{
	global Spec baseoutcome(4) vce(cluster ID)
}

** set addstat
{
global Add_stat  Wald chi2(42), 				e(chi2), ///
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
{
mlogit globsol $Main_IV $main_cntrls   if year<2014, $Spec
estimates store  Model_main
fitstat
}

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


** distribution main vars 
{
vioplot ln_dis_death	if e(sample), 	over(globsol) ///
										scheme(plotplain) ///
										title("Dis. fat.") ///
										name(Vio1, replace) ///
										ytitle("") ///
										xtitle("GlobSol values")	
	
	
vioplot KOF_pol 		if e(sample), 	over(globsol) ///
										scheme(plotplain) ///
										title("KOF pol.") ///
										name(Vio2, replace) ///
										ytitle("") ///
										xtitle("GlobSol values")
							  
vioplot ln_milper 		if e(sample), 	over(globsol) ///
										scheme(plotplain) ///
										title("Mil. per.") ///
										name(Vio3, replace) ///
										ytitle("") ///
										xtitle("GlobSol values") 

vioplot strat 			if e(sample), 	over(globsol) /// 
										scheme(plotplain) ///
										title("Srat. rents") ///
										name(Vio4, replace) ///
										ytitle("") ///
										xtitle("GlobSol values")

									
									
									
graph combine Vio1 Vio2 Vio3 Vio4, col(2) title("Distribution of main indipendent variables") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphA.png", as(png) name("combined") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphA.png", as(png) name("combined") replace


graph drop  Vio1 Vio2 Vio3
}


** corr matrix
{
correlate   $Main_IV $main_cntrls  if e(sample)
matrix corrmatrix = r(C)
heatplot corrmatrix, label ///
xlab(, angle(45)) ///
graphregion(fcolor(white)) ///
colors(hcl diverging ,gscale) ///
values(format(%4.2f) size(vsmall)) legend(off) cuts(-1(`=2/15')1) scheme(plotplain) name(corr_matrix, replace)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\Corr_matrix.png", as(png) replace	
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\Corr_matrix.png", as(png) name("corr_matrix") replace
}



** distribution covariates 1 
{
* Create individual violin plots for each variable
vioplot inf_mort_rate_lag_1    if e(sample), 	over(globsol) ///
												name(Vio1,replace) ///
												title("Inf. mort.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
g conf_label =""
replace conf_label= "Conf.=1" if ongoing_conf==1
replace conf_label= "Conf.=0" if ongoing_conf==0
	

g gs_label =""
replace gs_label= "GS.=1" if globsol==1
replace gs_label= "GS.=2" if globsol==2
replace gs_label= "GS.=3" if globsol==3
replace gs_label= "GS.=4" if globsol==4

	
graph bar (percent) 			if e(sample), 	over(conf_label) ///
												over(gs_label) ///
												title("Conf.") ///
												ytitle("Percentage") ///
												horizontal ///
												scheme(plotplain) ///
												name(barplot1, replace)	

	
	
vioplot ln_pop_tot_lag_1  		if e(sample), 	over(globsol) ///
												name(Vio3,replace) ///
												title("Pop.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
												
vioplot age_dep_ratio_lag_1  	if e(sample), 	over(globsol) ///
												name(Vio4,replace) ///
												title("Age dep.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 													
												
												
vioplot inflation_lag_1  		if e(sample), 	over(globsol) ///
												name(Vio5,replace) ///
												title("Inflation") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 

vioplot autonomy_lag_1 			if e(sample), 	over(globsol) ///
												name(Vio6,replace) ///
												title("Autonomy") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 

												
												

			
* Combine the plots into a single graph
graph combine Vio1 barplot1 Vio3 Vio4 Vio5 Vio6, col(3) title("Distribution of covariates, pt. 1") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphB.png", as(png) name("combined") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphB.png", as(png) name("combined") replace
drop gs_label conf_label

graph drop  Vio1 barplot1 Vio3 Vio4 Vio5 Vio6
}
****

** distribution covariates 2
{
* Create individual violin plots for each variable

vioplot trade_lag_1  			if e(sample), 	over(globsol) ///
												name(Vio1,replace) ///
												title("Trade") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot fdi_lag_1  				if e(sample), 	over(globsol) ///
												name(Vio2,replace) ///
												title("FDI")  ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	


vioplot rpe_agri_lag_1 			 if e(sample), 	over(globsol) ///
												name(Vio3,replace) ///
												title("RPE") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 

vioplot ln_gdp_pc_lag_1			if e(sample), 	over(globsol) ///
												name(Vio4,replace) ///
												title("GDP") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot liberal_demo_lag_1  	if e(sample), 	over(globsol) ///
												name(Vio5,replace) ///
												title("Dem. index.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
	
vioplot military_centr_lag_1  	if e(sample), 	over(globsol) ///
												name(Vio6,replace) ///
												title("Mil. cen.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 		
	

			
* Combine the plots into a single graph
graph combine Vio1 Vio2 Vio3 Vio4 Vio5 Vio6, col(3) title("Distribution of covariates, pt. 2") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphC.png", as(png) name("combined") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphC.png", as(png) name("combined") replace

graph drop  Vio1 Vio2 Vio3 barplot1 Vio5 Vio6
}
****

** distribution covariates 3
{

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
												
vioplot v2regdur			  	if e(sample), 	over(globsol) ///
												name(Vio2,replace) ///
												title("Reg. dur.") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 												
												
	
vioplot ns_donors_ratio_lag_1	if e(sample), 	over(globsol) ///
												name(Vio3,replace) ///
												title("Donors. ratio") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 		
	
vioplot count_ho_lag_1  		if e(sample), 	over(globsol) ///
												name(Vio4,replace) ///
												title("H.O.")  ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 	
	

vioplot rugged			  		if e(sample), 	over(globsol) ///
												name(Vio5,replace) ///
												title("Rugged") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
vioplot tropical			  	if e(sample), 	over(globsol) ///
												name(Vio6,replace) ///
												title("Tropical") ///
												xtitle("GlobSol values") ///
												scheme(plotplain) 
	
* Combine the plots into a single graph
graph combine barplot1 Vio2 Vio3 Vio4 Vio5 Vio6, col(3) title("Distribution of covariates, pt. 3") scheme(plotplain)  name(combined,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphC.png", as(png) name("combined") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphC2.png", as(png) name("combined") replace

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
sortvar 	(   $Main_IV  ) ///
keep 		(   $Main_IV ) ///
addstat 	(   $Add_stat ) ///
tex dec(3) pdec(3) ///
addtext(Dyad FE,				YES, ///
Year FE, 						YES, ///
Cluster SE, 					YES) ///
replace  label   

}




** coef plot fatalities
** di fat
{
estimates restore  Model_main
sum ln_dis_death    if e(sample),d

	estimates restore  Model_main
	margins, dydx(ln_dis_death) ///
	at(ln_dis_death=(.7 4 5 6 10)) ///
	predict(outcome(3)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Coercive Solidarity) title("")  ///
	name(marg_plot_1,replace) 	
	
	estimates restore  Model_main
	margins, dydx(ln_dis_death) ///
	at(ln_dis_death=(.7 4 5 6 10)) ///
	predict(outcome(1)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Full Solidarity) title("") ///
	name(marg_plot_2,replace) 		

	estimates restore  Model_main
	margins, dydx(ln_dis_death) ///
	at(ln_dis_death=(.7 4 5 6 10)) ///
	predict(outcome(4)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Minimal Solidarity) title("") ///
	name(marg_plot_3,replace) 

	estimates restore  Model_main
	margins, dydx(ln_dis_death) ///
	at(ln_dis_death=(.7 4 5 6 10)) ///
	predict(outcome(2)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Symbolic Solidarity) title("") ///
	name(marg_plot_4,replace) 	
	

graph combine marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	, xcommon col(2) title("Marginal effects of Dis. fat. on predicted prob.") scheme(plotplain)  name(combined1,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphD.png", as(png) name("combined1") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphD.png", as(png) name("combined1") replace
graph drop  marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	
}	

** KOF index	
{
	
estimates restore  Model_main
sum  KOF_cu   if e(sample),d

	estimates restore  Model_main
	margins, dydx(KOF_cu) atmeans  ///
	at(KOF_cu=(8 29 45 54 91)) ///
	predict(outcome(3)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Coercive Solidarity) title("")  ///
	name(marg_plot_1,replace) 	
	
	estimates restore  Model_main
	margins, dydx(KOF_cu) atmeans  ///
	at(KOF_cu=(8 29 45 54 91)) ///
	predict(outcome(1)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Full Solidarity) title("") ///
	name(marg_plot_2,replace) 		

	estimates restore  Model_main
	margins, dydx(KOF_cu) atmeans  ///
	at(KOF_cu=(8 29 45 54 91)) ///
	predict(outcome(4)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Minimal Solidarity) title("") ///
	name(marg_plot_3,replace) 

	estimates restore  Model_main
	margins, dydx(KOF_cu) atmeans  ///
	at(KOF_cu=(8 29 45 54 91)) ///
	predict(outcome(2)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Symbolic Solidarity) title("") ///
	name(marg_plot_4,replace) 	
	

graph combine marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	, xcommon col(2) title("Marginal effects of KOF pol. on predicted prob.") scheme(plotplain)  name(combined2,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphE.png", as(png) name("combined2") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphE.png", as(png) name("combined2") replace
graph drop  marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	

}	
	
** strat index	
{
	
estimates restore  Model_main
sum  strat   if e(sample),d

	estimates restore  Model_main
	margins, dydx(strat) atmeans ///
	at(strat=(0.24 1.6 5 38)) ///
	predict(outcome(3)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Coercive Solidarity) title("")  ///
	name(marg_plot_1,replace) 	
	
	estimates restore  Model_main
	margins, dydx(strat) atmeans ///
	at(strat=(0.24 1.6 5 38)) ///
	predict(outcome(1)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Full Solidarity) title("") ///
	name(marg_plot_2,replace) 		

	estimates restore  Model_main
	margins, dydx(strat) atmeans ///
	at(strat=(0.24 1.6 5 38)) ///
	predict(outcome(4)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Minimal Solidarity) title("") ///
	name(marg_plot_3,replace) 

	estimates restore  Model_main
	margins, dydx(strat) atmeans ///
	at(strat=(0.24 1.6 5 38)) ///
	predict(outcome(2)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Symbolic Solidarity) title("") ///
	name(marg_plot_4,replace) 	
	

graph combine marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	, xcommon col(2) title("Marginal effects of Mil per. on predicted prob.") scheme(plotplain)  name(combined3,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GraphF.png", as(png) name("combined3") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphF.png", as(png) name("combined3") replace
graph drop  marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	
	
	}	
	
	
	
** Milper index	
{
	
estimates restore  Model_main
sum  ln_milper   if e(sample),d

	estimates restore  Model_main
	margins, dydx(ln_milper) atmeans ///
	at(ln_milper=(9 11 12 13 15)) ///
	predict(outcome(3)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Coercive Solidarity) title("")  ///
	name(marg_plot_1,replace) 	
	
	estimates restore  Model_main
	margins, dydx(ln_milper) ///
	at(ln_milper=(9 11 12 13 15)) ///
	predict(outcome(1)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Full Solidarity) title("") ///
	name(marg_plot_2,replace) 		

	estimates restore  Model_main
	margins, dydx(ln_milper) ///
	at(ln_milper=(9 11 12 13 15)) ///
	predict(outcome(4)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Minimal Solidarity) title("") ///
	name(marg_plot_3,replace) 

	estimates restore  Model_main
	margins, dydx(ln_milper) ///
	at(ln_milper=(9 11 12 13 15)) ///
	predict(outcome(2)) post
	marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) ///
	scheme(plotplain) ///
	xtitle(Effect on pr. Symbolic Solidarity) title("") ///
	name(marg_plot_4,replace) 	
	

graph combine marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	, xcommon col(2) title("Marginal effects of Mil per. on predicted prob.") scheme(plotplain)  name(combined4,replace) 
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\GrapG.png", as(png) name("combined4") replace
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\GraphG.png", as(png) name("combined4") replace
graph drop  marg_plot_1 marg_plot_2 marg_plot_3 marg_plot_4	
	
	}
	
	
	
	
** figure
{
	
estimates restore  Model_main
sum  ln_dis_death KOF_cu  ln_milper  strat  if e(sample)

margins , at(ln_dis_death = (0(0.2) 12)) atmeans predict(outcome(4))
marginsplot, name(p1, replace) $layout ytitle(pr. Minimal Solidarity)
margins , at(ln_dis_death = (0(0.2) 12)) atmeans predict(outcome(1))
marginsplot, name(p2, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_dis_death = (0(0.2) 12)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_dis_death = (0(0.2) 12)) atmeans predict(outcome(2))
marginsplot, name(p4, replace) $layout ytitle(pr. Symbolic Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g1, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G1.png", as(png) name("g1") replace	
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\G1.png", as(png) name("g1") replace

margins , at(KOF_cu = (8(2) 94)) atmeans predict(outcome(4))
marginsplot, name(p1, replace) $layout ytitle(pr. Minimal Solidarity)
margins , at(KOF_cu = (8(2) 94)) atmeans predict(outcome(1))
marginsplot, name(p2, replace) $layout ytitle(pr. Full Solidarity)
margins , at(KOF_cu = (8(2) 94)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(KOF_cu = (8(2) 94)) atmeans predict(outcome(2))
marginsplot, name(p4, replace)$layout ytitle(pr. Symbolic Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g2, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G2.png", as(png) name("g2") replace	
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\G2.png", as(png) name("g2") replace


margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p1, replace) $layout ytitle(pr. Minimal Solidarity)
margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p2, replace) $layout ytitle(pr. Full Solidarity)
margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p4, replace) $layout ytitle(pr. Symbolic Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3.png", as(png) name("g3") replace	
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\G3.png", as(png) name("g3") replace

margins , at(ln_milper = (4(.5) 15)) atmeans predict(outcome(4))
marginsplot, name(p1, replace) $layout ytitle(pr. Minimal Solidarity)
margins , at(ln_milper = (4(.5) 15)) atmeans predict(outcome(1))
marginsplot, name(p2, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_milper = (4(.5) 15)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_milper = (4(.5) 15)) atmeans predict(outcome(2))
marginsplot, name(p4, replace) $layout ytitle(pr. Symbolic Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g4, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G4.png", as(png) name("g4") replace	
graph export "C:\Users\marco\Nextcloud\Global Solidarity\Paper on Natural Disasters\figures\G4.png", as(png) name("g4") replace

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

margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(4))
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

margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, Srat(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, Srat(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Srat = (0(1.5) 50)) atmeans predict(outcome(4))
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

margins , at(Oil_min = (0(1.5) 34)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(Oil_min = (0(1.5) 34)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(Oil_min = (0(1.5) 34)) atmeans predict(outcome(3)) 
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(Oil_min = (0(1.5) 34)) atmeans predict(outcome(4))
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

g ln_milper = ln(mil_per_lag_1)
label var 	ln_milper		"Mil. size"
g ln_milexp = ln(mil_exp_usd_lag_1)
label var 	ln_milexp		"Mil. exp"

g NR = 		nat_rents_lag_1
label var 	NR			 	"Nat. rents"
g strat = 	oil_rents_lag_1+minerals_rents_lag_1+gas_rents_lag_1
label var 	strat			 	"Strat. rents"
g Oil 	= 	oil_rents_lag_1
label var 	Oil			 	"Oil rents"

}

** gen and label controls
{
encode iso3c, generate(ID)


g ln_inf_mort_rate_lag_1= ln(inf_mort_rate_lag_1)
g ln_dis_death=ln(dis_death)

g ongoing_conf=0
replace ongoing_conf=1 if best_fat_lag_1>0

g ln_inflation_lag_1=ln(inflation_lag_1)
g ln_pop_tot_lag_1= ln(pop_tot_lag_1)

g ln_fdi_lag_1= fdi_lag_1
g ln_trade_lag_1=trade_lag_1

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
global Need				ln_inf_mort_rate_lag_1  ln_pop_tot_lag_1 				 
global Merit			ln_inflation_lag_1 		autonomy_lag_1
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
global Main_IV 			KOF_pol ln_milper 	strat ln_dis_death
** alt trade
global Main_IV_atr 		KOF_cu 	ln_milper 	strat ln_dis_death
** alt ME
global Main_IV_ame 		KOF_pol ln_milexp 	strat ln_dis_death
** alt NR
global Main_IV_anr 		KOF_pol ln_milper	NR 	  ln_dis_death
** alt All
global Main_IV_all 		KOF_cu 	ln_milexp	NR 	  ln_dis_death
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

vioplot Srat 		if e(sample), 	over(globsol) /// 
									scheme(plotplain) ///
									title("Srat. rents") ///
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


** coef plot
	
	estimates restore  Model_main
margins, dydx(KOF_pol) at(KOF_pol=(30 50 70 90)) predict(outcome(1)) post
marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) xline(0) scheme(plotplain)		

estimates restore  Model_main
margins, dydx(ln_milper) at(ln_milper=(4 6 8 10 12 14)) predict(outcome(2)) post
marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) xline(0) scheme(plotplain)		

	
	estimates restore  Model_main
margins, dydx(strat) at(strat=(0 1 5 10 38)) predict(outcome(3)) post
marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) xline(0) scheme(plotplain)		

	estimates restore  Model_main
margins, dydx(ln_dis_death) at(ln_dis_death=(0 1 2 5 10)) predict(outcome(4)) post
marginsplot, recast(scatter) ///
    horizontal  ///
    plotopts(msymbol(O) msize(large)) ///
    xline(0, lpattern(dash)) xline(0) scheme(plotplain)		
				
	
	
	
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

margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(strat = (0(1.5) 50)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g3, replace) scheme(plotplain)
graph export "C:\Users\marco\Desktop\DFGlobalLab\Compiled\G3.png", as(png) name("g3") replace	

graph drop p1 p2 p3 p4

}


margins , at(ln_dis_death = (0(0.5) 10)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) $layout ytitle(pr. Full Solidarity)
margins , at(ln_dis_death = (0(0.5) 10)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) $layout ytitle(pr. Symbolic Solidarity)
margins , at(ln_dis_death = (0(0.5) 10)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) $layout ytitle(pr. Coercive Solidarity)
margins , at(ln_dis_death = (0(0.5) 10)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) $layout ytitle(pr. Minimal Solidarity)
graph combine p1 p2 p3 p4, ycommon name(g4, replace) scheme(plotplain)






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











