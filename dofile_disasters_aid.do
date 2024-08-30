
** import data
import delimited "C:\Users\marco\Desktop\DFGlobalLab\Compiled\df_full.csv", clear
encode iso3c, generate(ID)

g dummy_war_terror=0
replace dummy_war_terror=1 if year>2001

g non_agri_va = 100-agricolture_va_lag_1

** set variables
global econ_deve  trade_lag_1  urb_pop_pct_lag_1 inflation_lag_1 inf_mort_rate_lag_1
global conflict best_fat_lag_1  military_exp_pct_gov_exp_lag_1
global pol liberal_demo_lag_1 
global geo_colonial desert colony_esp colony_gbr colony_fra colony_prt  colony_oeu
global additional  rpe_agri_lag_1  inf_mort_rate_lag_1

** model 1
global Main_IV kofpogidf_lag_1  ln_gdp_lag_1  nat_rents_lag_1 

mlogit globsol $Main_IV i.dummy_war_terror, baseoutcome(4) vce(cluster ID) 
mlogit globsol $Main_IV $econ_deve i.dummy_war_terror, baseoutcome(4) vce(cluster ID)
mlogit globsol $Main_IV $geo_colonial i.dummy_war_terror, baseoutcome(4) vce(cluster ID)
mlogit globsol $Main_IV $conflict i.dummy_war_terror, baseoutcome(4) vce(cluster ID)
mlogit globsol $Main_IV $econ_deve $geo_colonial $conflict i.dummy_war_terror, baseoutcome(4) vce(cluster ID)

correlate globsol $Main_IV $econ_deve $geo_colonial $conflict if e(sample)
matrix corrmatrix = r(C)
heatplot corrmatrix, label ///
xlab(, angle(45)) ///
graphregion(fcolor(white)) ///
colors(hcl diverging ,gscale) ///
values(format(%4.3f)) legend(off) cuts(-1(`=2/15')1)


** alt trade
global Main_IV koftrgidf_lag_1 ln_gdp_lag_1 nat_rents_lag_1
mlogit globsol $Main_IV $econ_deve $geo_colonial $conflict i.dummy_war_terror, baseoutcome(4) vce(cluster ID)

** alt gdp
global Main_IV kofpogidf_lag_1 gdp_per_cap_ppp_lag_1 nat_rents_lag_1
mlogit globsol $Main_IV $econ_deve $geo_colonial $conflict i.dummy_war_terror, baseoutcome(4) vce(cluster ID)

** alt natrev
global Main_IV koftrgidf_lag_1 ln_gdp_lag_1 oil_rents_lag_1
mlogit globsol $Main_IV $econ_deve $geo_colonial $conflict i.dummy_war_terror, baseoutcome(4) vce(cluster ID)

** alt all
global Main_IV kofpogidf_lag_1 ln_gdp_lag_1 oil_rents_lag_1
mlogit globsol $Main_IV $econ_deve $geo_colonial $conflict i.dummy_war_terror, baseoutcome(4) vce(cluster ID)




*******************
global econ_deve  ln_trade_lag_1  urb_pop_pct_lag_1 inflation_lag_1 inf_mort_rate_lag_1
global conflict best_fat_lag_1  military_exp_pct_gdp_lag_1
global pol liberal_demo_lag_1 
global geo_colonial desert colony
global additional  rpe_agri_lag_1  


global Main_IV kofpogidf_lag_1  ln_gdp_lag_1  nat_rents_lag_1 
mlogit globsol $Main_IV $econ_deve $geo_colonial $pol $conflict $additional $disaster_lag i.dummy_war_terror, baseoutcome(4) vce(cluster ID)

mlogit globsol $Main_IV $econ_deve $geo_colonial $pol $conflict $additional  i.dummy_war_terror if year<2014, baseoutcome(4) vce(cluster ID)


correlate  $Main_IV $econ_deve $geo_colonial $pol $conflict  $additional if e(sample)
matrix corrmatrix = r(C)
heatplot corrmatrix, label ///
xlab(, angle(45)) ///
graphregion(fcolor(white)) ///
colors(hcl diverging ,gscale) ///
values(format(%4.3f)) legend(off) cuts(-1(`=2/15')1)

margins , at(kofpogidf_lag_1 = (0(2) 100)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(kofpogidf_lag_1 = (0(2) 100)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(kofpogidf_lag_1 = (0(2) 100)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(kofpogidf_lag_1 = (0(2) 100)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
graph combine p1 p2 p3 p4, ycommon name(g1, replace)

margins , at(ln_gdp_lag_1 = (20(1) 30)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(ln_gdp_lag_1 = (20(1) 30)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(ln_gdp_lag_1 = (20(1) 30)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(ln_gdp_lag_1 = (20(1) 30)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
graph combine p1 p2 p3 p4, ycommon name(g2, replace)

margins , at(nat_rents_lag_1 = (0(5) 80)) atmeans predict(outcome(1))
marginsplot, name(p1, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(nat_rents_lag_1 = (0(5) 80)) atmeans predict(outcome(2))
marginsplot, name(p2, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(nat_rents_lag_1 = (0(5) 80)) atmeans predict(outcome(3))
marginsplot, name(p3, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
margins , at(nat_rents_lag_1 = (0(5) 80)) atmeans predict(outcome(4))
marginsplot, name(p4, replace) scheme(plotplain)  recast(line)  ciopt(color(black%20))
graph combine p1 p2 p3 p4, ycommon name(g3, replace)





global disaster  dis_count
global disaster_lag dis_count_lag_1
global disaster_extended biological_dummy_50k climatological_dummy_50k geophysical_dummy_50k  hydrological_dummy_50k meteorological_dummy_50k
global disaster_extended_lag biological_dummy_lag_1_50k climatological_dummy_lag_1_50k geophysical_dummy_lag_1_50k  hydrological_dummy_lag_1_50k meteorological_dummy_lag_1_50k




mlogit globsol $Main_IV $econ_deve $geo_colonial $conflict $additional i.dummy_war_terror, baseoutcome(4) vce(cluster ID)










