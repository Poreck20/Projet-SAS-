
    	/*===============================================================================================*/

      	   /*     ANALYSE DES DETERMINANTS DES ECHANGES COMMERCIAUX : PERSPECTIVES ECONOMETRIQUES    */
	      /*                  ETUDIANT : DIALLO Alpha, M1 MASERATI & GPIA                          */

	   /*=================================================================================================*/




    	/*===========================================================================*/
	 		 /*                           DEBUT DU CODE                         */
	
	 		/*                      IMPORTATION DES TABLES BACI                */
	
		/*========================================================================*/

libname in "C:\Documents alpha\SAS PROJET" ;


%macro baci_in(i,j);
	%do i=&i %to &j;
		data baci_&i; infile "C:\Documents alpha\SAS PROJET\Exercice Fac\Donne cepii baci\RPROD\BACI_Y&i..csv"
			dlm = ","
			dsd
			firstobs = 2;
			input year exporter importer product $ value quantity;
		run;
		proc sort data = baci_&i;
			by year exporter importer product value quantity;
		run;
	%end;
%mend ;

%baci_in(1998,2002);

proc print data = baci_2002 (obs=10) ; run; 


/*Concatenation des tables baci*/

data table_baci ; 
	set  baci_1998 baci_1999 baci_2000 baci_2001 baci_2002 ; 
		by year exporter importer product value quantity ;
run ; 

data in.table_baci ; set table_baci ; run ; 
proc contents data = table_baci ; run ;
proc print data = table_baci (obs=10) ; run ;


   		 /*========================================================================*/
	
	 		/*                           PAYS DE L'OCDE                      */
	
		/*========================================================================*/
                     

proc import out = ocde 
	datafile = "C:/Documents alpha/SAS PROJET/Exercice Fac/livre 3.xlsx"
	dbms = xlsx replace ; 
run ; 


proc print data = ocde ; run ; 
proc contents data = ocde ; run ; 
 
proc sort data = ocde ; 
	by exporter; 
run ; 

proc sort data = table_baci ; 
	by exporter ; 
run ; 


data table_baci1; merge table_baci(in=a)  ocde (in=b) ;  
	if a and b ;
	by exporter ;
run ; 

data table_baci1 ; set table_baci1 ; 
	rename Nom_du_pays = pays_exporter ;
	rename iso_alpha = iso_exporter ;  
run ; 

proc print data = table_baci1 (obs=100) ; run ; 


/*Faisons avec les importer */

data ocde ; set ocde; 
	rename exporter = importer ;
	rename Nom_du_pays = pays_importer ;
	rename iso_alpha = iso_importer ;  
run ; 

proc print data = ocde (obs=100) ; run ; 


proc sort data = ocde ; 
	by importer; 
run ; 

proc sort data =  table_baci1 ; 
	by importer ; 
run ; 


data table_baci_ocde; merge table_baci1(in=a)  ocde (in=b) ;  
	if a and b ;
	by importer;
run ; 

data in.table_baci_ocde ; set table_baci_ocde; run ;
proc print data = table_baci_ocde(obs=200) ; where (quantity=.) ; run ;



   		 /*========================================================================*/
	
	 		/*                  MPORTATION DES TABLES GDP ET POP                */
	
		/*========================================================================*/


/*La table de gdp*/

data base_test ;
	infile "C:\Documents alpha\SAS PROJET\Exercice Fac\gdp_V20220706.csv" 
	dlm = ","; 
	input country $ indicator $ v1960 v1961 v1962 v1963 v1964 v1965 v1966 v1967 v1968 v1969 v1970 v1971 v1972 v1973 v1974 v1975 v1976 v1977 v1978 v1979 v1980 v1981 v1982 v1983 v1984 v1985 v1986 v1987 v1988 v1989 v1990 v1991 v1992 v1993 v1994 v1995 v1996 v1997 v1998 v1999 v2000 v2001 v2002 v2003 v2004 v2005 v2006 v2007 v2008 v2009 v2010 v2011 v2012 v2013 v2014 v2015 v2016 v2017 v2018 v2019 v2020 v2021 v2022 v2023 v2024 v2025 v2026 v2027;
run ; 
proc print data = base_test (obs= 2000) ; run ; 

 
data gdp ; set base_test ; 
	keep country indicator v1998 v1999 v2000 v2001 v2002 ;
run ; 

proc print data = gdp ; run ; 

/*Gardons que le GDP-PPP PIB parité pouvoir d'achat*/
data gdp ; set gdp ; 
	if indicator = "GDP-PPP" ;
run ; 

/*Extraire la pop comme une table en gardans que les annee de 1998 a 2012 */
data pop ; set base_test ; 
	keep country indicator v1998 v1999 v2000 v2001 v2002;
run ; 

data pop ; set pop ; 
	if indicator = "POP" ; 
run ; 

proc print data = pop(obs=10) ; run ; 
proc print data = gdp(obs=10) ; run  ; 



/* Tranposition de la var gpd Étape 1 : Transposer les colonnes des années */
proc transpose data=gdp out=gdp_trans;
    by indicator country;
    var v1998 v1999 v2000 v2001 v2002 ;         
run;

proc print data = gdp_trans ; run ; 

data gdp_trans ; set gdp_trans ; 
	rename _NAME_ = Year ;
	rename  COL1 = PIB ; 
run ; 


/*Transposition de la var population*/
proc transpose data= pop out=pop_trans;
    by country indicator;           
    var v1998 v1999 v2000 v2001 v2002;      
run;

proc print data = pop_trans(obs=100) ; run ; 


data pop_trans ; set pop_trans ; 
	rename _NAME_ = Year ; 
	rename  COL1  = Population ; 
run ; 

/*On va fusionnner les deux tables pour avoir gdp et pop sur la meme table*/

proc sort data = pop_trans ; 
	by Year country; 
run ; 

proc sort data = gdp_trans ; 
	by Year country; 
run ; 


data table_gp ; merge gdp_trans pop_trans ; 
	by Year country ; 
run ; 

proc sort data = table_gp ; 
	by country ; 
run ; 

proc print data =  table_gp ; where country="FRA" ; run ; 


/*Enlever le v a coté des annees */
data table_gp; set table_gp ; 
    year = substr(year, 2); /* Enlève le premier caractère (le "v") */
run;


/*Renommer quelques noms*/
data table_gp ; set table_gp ; 
	rename	Country = Pays
			PIB = PIB_PPP
			Year = Annee ;
	drop indicator ; 
run ; 

proc print data = table_gp (obs=100) ; run ; 

/*Gardons la table finale dans la librairie permanente*/
data in.table_gp ; 
	set table_gp ; 
run ;


   		 /*========================================================================*/
	
	 		/*                     IMPORTATION DE LA TABLE DISTANCE             */
	
		/*========================================================================*/


proc import out = table_dist 
	datafile = "C:\Document\SAS Projet\Exercice Fac\dist_cepii.xls"
	dbms = xls ; 
run ; 

proc print data = table_dist (obs=100) ; run ; 

data table_dist ; set table_dist ;
	keep dist iso_o iso_d ;
run ;  

/*Pour un meme pays la distance est de 0, plus logique*/
data table_dist ; set table_dist ; 
	if iso_o = iso_d then dist = 0 ;
run ;

/*Gardons la table finale dans la librairie permanente*/
data in.table_dist ; set table_dist ; 
run ; 


   		 /*========================================================================*/
	
	 		/*                            MERGE			      	                */
	
		/*========================================================================*/


/*Ci dessous les tables qu'il faut merger*/
proc print data = in.table_dist(obs=10) ; run ; /*Table de distance*/
proc print data = in.table_gp (obs=20) ; run ;/*Table de PIB et Population*/
proc print data = table_baci_ocde(obs=10) ; run ; /*Table basic final */



		/*=============================TABLE GP ET BACI =============================*/ 
   
proc print data = table_gp (obs=50) ; run ;
proc print data = table_baci_ocde (obs=5) ; run ; 


/*Pour avoir les gpd et pop du pays importateur(iso_o)*/
data table_gp_expor ; set table_gp ; 
rename
	Pays = iso_exporter
	PIB_PPP = pib_exporter 
	Population = pop_exporter ; 
run ; 


/*Converstissons annee en variable numérique*/
data table_gp_expor ; set table_gp_expor; 
	year = input(annee, 8.) ;
	drop annee ; 
run ;

proc contents data = table_gp_expor ; run;
proc print data = table_gp_expor (obs=1000) ; run ;


/*Trions*/

proc sort data = table_gp_expor ; 
	by iso_exporter year; 
run ; 

proc contents data = table_baci_ocde ; run ; 

proc sort data =table_baci_ocde  ; 
	by iso_exporter year ; 
run ; 

data gp_baci ; merge table_baci_ocde (in=a) table_gp_expor (in=b); 
	if a and b ; 
	by iso_exporter year ; 
run ; 

proc print data = gp_baci (obs=10) ; run ; 



/*Pour avoir les gpd et pop du pays exportateur(iso_d)*/

data table_gp_impor ; set table_gp ; 
rename
	Pays = iso_importer
	PIB_PPP = pib_importer 
	Population = pop_importer ;  
run ; 

/*Converstissons annee en var numeric*/
data table_gp_impor ; set table_gp_impor; 
	year = input(annee, 8.) ;
	drop annee ; 
run ;

proc print data = table_gp_impor (obs=10) ; run ; 


proc sort data = table_gp_impor ; 
	by iso_importer year; 
run ; 

proc sort data = gp_baci ; 
	by iso_importer year ; 
run ; 
proc print data = gp_baci (obs=10) ; run ;


data gp_baci_final ; merge gp_baci (in=a) table_gp_impor (in=b); 
	by iso_importer year ; 
	if a and b ; 
run ; 

proc print data = gp_baci_final (obs=8000) ; run ;
data in.gp_baci_final ; set gp_baci_final ; run ; /*Enregistrons cette table dans la librairie permanente*/



		/*=========================TABLE BACI_GP ET DISTANCE ===========================*/ 


proc print data = gp_baci_final (obs=10) ; run ; 
data table_dist ; set in.table_dist ; run ; 
proc print data = table_dist (obs=10) ; run ; 


/* Fusion avec les données des exportateurs et importateurs*/
data table_dist;
   set table_dist ;
   rename iso_o = iso_exporter 
          iso_d = iso_importer  ;
run ; 

proc sort data =gp_baci_final; 
	by iso_exporter iso_importer; 
run;  
 
proc 
sort data=table_dist; 
	by iso_exporter iso_importer; 
run;    

data baci_gp_dist;
   merge gp_baci_final (IN=a) table_dist (IN=b);
   by iso_exporter iso_importer;
   if a and b ;
run;

proc print data = baci_gp_dist (obs=100) ; run ; 

data baci_gp_dist;
    retain year exporter iso_exporter pays_exporter pays_importer importer iso_importer dist pib_exporter  pib_importer pop_exporter pop_importer 
           product value quantity;
    set baci_gp_dist;
	run ;
 
proc print data = baci_gp_dist (obs=10) ; run ; 

data in.baci_gp_dist ; set baci_gp_dist ; /*enregistrons la table final avant vup dans la librairie permanente*/
run ; 



		/*=============================TABLE BACI_GP_DIST ET SECTEUR =============================*/ 

proc import out = code_product 
	datafile = "C:\Documents alpha\SAS PROJET\Exercice Fac\Donne cepii baci\donne secteur\HS1996.xls"
	dbms = xls replace ; 
run ;

proc print data = code_product(obs=1000) ; run ;  

data code_product ; set code_product ; 
	drop c A Conversion_table_HS1996_to_SITC_  f g h;
	if _N_ > 7 ;
	rename d= HS96 ;
	rename e = S3 ;
run ; 


/*Creons la colonne secteur*/
data code_product ; set code_product ; 
	secteur = substr(S3, 1,2) ;
	drop s3 ;
run ;

proc print data = code_product (obs=1000) ; run ;



/*===================================MERGE TABLE_FINALE ET TABLE SETEUR==========================================*/

proc sort data = baci_gp_dist ; 
	by product ; 
run ; 
proc print data = baci_gp_dist (obs=10) ;where (quantity=.) ; run ; 


/*convertissons product en texte*/
data code_product ; set code_product ; 
	product = put(HS96,8.) ; 
	drop HS96 ; 
run ; 

proc sort data = code_product ; 
	by product; 
run ; 

data table_finale ; merge code_product (in=a) baci_gp_dist (in=b); 
	by product ; 
	if a and b ; 
run ; 

proc print data = table_finale (obs=1000) ; run ;



   		 /*========================================================================*/
	
	 		/*               CALCUL DE LA VALEUR UNITAIRE PONDERE	            */
	
		/*========================================================================*/


/*==============ETAPE 1: la ponderation = Volume_unitaire/quantite_total par secteur==================*/
proc sql; 
	create table table_finale1 
	as select*,
    	quantity/sum(quantity) as ponderation
	from table_finale
	group by year, exporter, importer, secteur ;
quit ; 

proc print data = table_finale1 (obs=2000) ; run ;


proc sql ; 
	create table table_finale2 
	as select*, 
		sum((value/quantity)*ponderation) as VUP
	from table_finale1 
	group by year, exporter, importer, secteur
	order by year, exporter, importer, secteur ; 
quit ; 

proc print data = table_finale2 (obs=200) ; run ;


data base_finale;
    retain year exporter iso_exporter pays_exporter pays_importer importer iso_importer secteur product value quantity ponderation vup 
	dist pib_exporter  pib_importer pop_exporter pop_importer product value quantity ponderation vup;
 
    set table_finale2;
run ;


proc print data = base_finale (obs=2) ; run ;


/*AJOUT DES LABELS*/

data in.base_finale ; set in.base_finale ; 
label	year = year
		exporter = exporter
		iso_exporter = iso_exporter
		pays_exporter = pays_exporter
		pays_importer = pays_importer
		importer = importer
		iso_importer = iso_importer
		secteur = secteur
		product = product
		value = value
		quantity = quantity
		ponderation = ponderation
		vup = vup
		dist = dist
		pib_exporter = pib_exporter
		pib_importer = pib_importer
		pop_exporter = pop_exporter
		pop_importer = pop_importer ; 

run ; 

		/*=========================BASE FINALE AVANT INDICATRICE============================*/
data in.base_finale ; 
	set base_finale ; 
run ;



   		 /*========================================================================*/
	
	 		/*                       VARIABLES INDICATRICES	                   */
	
		/*========================================================================*/

/*=======================================INDICATRICES PAYS===========================================*/

%let iso_list = AUS AUT BEL CAN CHE CHL COL CRI CZE DEU DNK ESP EST FIN FRA GBR GRC HUN IRL ISL ISR ITA JPN KOR LTU LUX LVA MEX NLD NOR NZL POL PRT SVK SVN SWE TUR USA;

data base_finale;
    set in.base_finale; 
    
    %macro creer_indicateurs;
        %let i = 1;

        %do %while (%scan(&iso_list, &i) ne %str());
            %let iso = %scan(&iso_list, &i);

            if iso_exporter = "&iso" then &iso._i = 1;
            else &iso._i = 0;

            if iso_importer = "&iso" then &iso._j = 1;
            else &iso._j = 0;

            %let i = %eval(&i + 1);
        %end;
    %mend;

    %creer_indicateurs;
run;

proc print data=base_finale(obs=10); run;

data in.base_finale ; 
	set base_finale ; 
run ; 


/*=======================================INDICATRICES ANNEE===========================================*/

%let ind_year = 1998 1999 2000 2001 2002;

data base_finale; 
    set in.base_finale;
  
    %macro cree_indicateur;
        %let i = 1;

        %do %while (%scan(&ind_year, &i) ne %str());
            %let ind = %scan(&ind_year, &i);

            if year = &ind then year_&ind = 1; 
            else year_&ind = 0;

            %let i = %eval(&i + 1);
        %end;
    %mend;

    %cree_indicateur;
run;

proc print data=base_finale(obs=10);  run;

data in.base_finale ; 
	set base_finale ; 
run ;

data base_finale ; set in.base_finale ; run ; 


   		 /*========================================================================*/
	
	 		/*                           LOG DES VARIABLES 	                   */
	
		/*========================================================================*/

data base_finale ; set in.base_finale ; 
    log_value = log(value);
    log_quantity = log(quantity);
    log_vup = log(vup);
    log_dist = log(dist);
    log_pib_exporter = log(pib_exporter);
    log_pib_importer = log(pib_importer);
    log_pop_exporter = log(pop_exporter);
    log_pop_importer = log(pop_importer);
run;
data in.base_finale ; set base_finale ; run ; 




   		 /*========================================================================*/
	
	 		/*                     STATISTIQUES DESCRIPTIVES                  */
	
		/*========================================================================*/


/*=====================================STATS DE BASE======================================*/

data base_finale ; set in.base_finale ; run ;
proc print data=base_finale (obs=100); where (secteur ="84"); run ;

ods graphics on ; 
ods excel file = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours\Stat_descriptive.xlsx" ; 

proc means data = base_finale N min mean median max std;
	Title "Statistiques Descriptives" ;
	var quantity vup dist pib_exporter pib_importer pop_exporter pop_importer ;
	output out = stat ;
run ;
proc print data = stat ; run ; 

ods excel close ;
ods graphics off ; 


/*=====================================DIAGRAMME DE LA VARIABLE YEAR======================================*/

ods graphics on / maxobs=10453016 ;
goptions reset=all device=png gsfname=grafout gsfmode=replace ;
filename grafout "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ; 
proc gchart data = base_finale ; 
	vbar year / levels=5 width=10 inside=percent;
	Title "Distribution de la variable year"; 
run ; quit ; 

ods graphics off ; 


/*==================================TOP 5 DES EXPORTATEURS/IMPORTATEURS==================================*/
proc sql ; 
	create table top_5_valeur as 
	select pays_exporter, pays_importer,
		sum(quantity) as total_valeur
	from base_finale 
	group by pays_exporter, pays_importer 
	order by total_valeur ;
quit ; 

proc sort data = top_5_valeur out=sorted_top_5 ;
	by descending total_valeur; 
run ; 


ods graphics on / maxobs=10453016 ;
ods graphics on / reset imagename = "Empilé exporter importer volume" imagefmt=png ;
ods listing gpath = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ;
proc sgplot data = sorted_top_5 (obs=25) ; 
	vbar pays_exporter / response=total_valeur stat=sum group=pays_importer groupdisplay=stack datalabel;
	xaxis label = "Exportateurs" ;
	yaxis label = "Valeur total des transactions" ; 
	title "Top 10 des principaux exportateurs/importateurs en termes de volume de transaction" ; 
run ; quit ; 


/*=====================================DISTRIBUTION DES SECTEURS======================================*/
ods graphics on / maxobs=10453016 ;
goptions reset=all device=png gsfname=grafout gsfmode=replace ;
filename grafout "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ; 
	proc gchart data = base_finale ; 
	pie secteur;
run ; quit ; 


/*==================================PRIX MOYEN PAR SECTEUR====================================*/
ods graphics on / maxobs=10453016 ;
ods graphics on / reset imagename = "Secteur" imagefmt=png ;
ods listing gpath = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ;
proc sgplot data = top_vup (obs=10) ;
	vbar secteur / response=vup stat=mean datalabel;
	xaxis label = "Secteur" ;
	yaxis label = "Prix Unitaire moyen pondéré (VUP)" ; 
	Title "Prix unitaire moyen par secteur" ;
run ; 



   		 /*========================================================================*/
	
	 		/*                       	MODELE DE REGRESSION 1	                */
	
		/*========================================================================*/


/*=================================SANS VARIABLE INDICATRICE============================================*/

ods graphics on ; 
ods excel file = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours\tableau_de_regression2.xlsx" ; 

proc reg data=base_finale;

    model log_quantity = log_vup log_pop_importer log_pop_exporter log_pib_exporter log_pib_importer log_dist ; 
                      
run;

ods excel close ;
ods graphics off ;


/*=================================MATRICE DE CORRELATION============================================*/
ods graphics on ; 
ods excel file = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours\matrice.xlsx" ; 
proc corr data =  base_finale nosimple; 
	var quantity vup dist pib_exporter pib_importer pop_importer pop_exporter ;
	title "Matrice de corrélations" ; 
run ; 

ods excel close ;
ods graphics off ; 

   		 /*========================================================================*/
	
	 		/*                       	MODELE DE REGRESSION 2                  */
	
		/*========================================================================*/

/*==================================AVEC VARIABLES INDICATRICES============================================*/

ods graphics on ; 
ods excel file = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours\tableau_de_regression.xlsx" ; 

proc reg data=base_finale;
    model log_quantity = log_vup log_pop_importer log_pop_exporter log_pib_exporter log_pib_importer log_dist 
                      AUS_i AUS_j AUT_i AUT_j BEL_i BEL_j CAN_i CAN_j 
                      CHE_i CHE_j CHL_i CHL_j COL_i COL_j CRI_i CRI_j 
                      CZE_i CZE_j DEU_i DEU_j DNK_i DNK_j ESP_i ESP_j 
                      EST_i EST_j FIN_i FIN_j GBR_i GBR_j 
                      FRA_i FRA_j HUN_i HUN_j IRL_i IRL_j ISL_i ISL_j 
                      ISR_i ISR_j ITA_i ITA_j JPN_i JPN_j KOR_i KOR_j 
                      LTU_i LTU_j LUX_i LUX_j LVA_i LVA_j MEX_i MEX_j 
                      NLD_i NLD_j NOR_i NOR_j NZL_i NZL_j POL_i POL_j 
                      PRT_i PRT_j SVK_i SVK_j SVN_i SVN_j SWE_i SWE_j 
                      TUR_i TUR_j USA_i USA_j
                      year_1999 year_2000 year_2001 year_2002;				  
run;

ods excel close ;
ods graphics off ;






		/*===============================AUTRES STATISTIQUEs================================*/

/*=====================FLUX COMMERCIAUX EN FONCTION DU PIB================================*/
proc sort data = base_finale ; by pib_exporter ; run ; 
proc print data = base_finale (obs=10); where (pays_exporter in ("États-Unis"))
and year=1998 ;
run ;

/*En terme de volume*/

ods graphics on / maxobs=10453016 ;
ods graphics on / reset imagename = "PIB_volume" imagefmt=png ;
ods listing gpath = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ;
proc sgplot data = base_finale (where=(pays_exporter in ("France", "États-Unis", "Japon", "Canada", "Allemagne") and pays_importer in("France", "États-Unis","Japon", "Canada", "Allemagne"))) ; 
	vbar pib_exporter / response=quantity stat=mean group=pays_importer datalabel;
	xaxis label = "Exportateur" ;
	yaxis label = "valeurs des transactions" ; 
	Title "Top 5 des exportateurs en termes de volume en fonction du PIB" ;
run ; 

/*En terme de valeur*/

ods graphics on / maxobs=10453016 ;
ods graphics on /  imagename = "PIB_valeur" imagefmt=png ;
ods listing gpath = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ;
proc sgplot data = base_finale (where=(pays_exporter in ("France", "États-Unis", "Japon", "Canada", "Allemagne") 
									and pays_importer in("France", "États-Unis","Japon", "Canada", "Allemagne"))) ; 
	vbar pib_exporter / response=value stat=mean group=pays_importer datalabel;
	xaxis label = "Exportateur" ;
	yaxis label = "valeurs des transactions" ; 
	Title "Top 5 des exportateurs en termes de valeur en fonction du PIB" ;
run ;


/*========================FLUX COMMERCIAUX EN FONCTION DE LA TAILLE DE LA POP================================*/

/*En terme de valeur de transaction*/
proc sql ;
	create table top_pop as 
	select distinct pop_exporter, pays_exporter 
	from base_finale ;
quit ; 

proc sort data = top_pop ; 
	by descending pop_exporter ;
run ; 

proc print data = top_pop (obs=10) ; run ; 

/* En terme de valeur*/
ods graphics on / maxobs=10453016 ;
ods graphics on / reset imagename = "Population_valeur" imagefmt=png ;
ods listing gpath = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ;
proc sgplot data = base_finale(where=(pays_exporter in ("France", "États-Unis", "Japon", "Royaume-Uni", "Allemagne")))  ;
	vbar pop_exporter / response=value stat=mean datalabel group=pays_exporter;
	xaxis label = "Population exportateur" ;
	yaxis label = "Valeur de transaction en moyenne" ; 
	Title "Flux commerciaux en fonction de la population exportateur en terme de valeur" ;
run ; 

/*En terme de volume*/
ods graphics on / maxobs=10453016 ;
ods graphics on / reset imagename = "Population_volume" imagefmt=png ;
ods listing gpath = "C:\Documents alpha\SAS PROJET\SAS Econometrie\base de donne secours" ;
proc sgplot data = base_finale(where=(pays_exporter in ("France", "États-Unis", "Japon", "Royaume-Uni", "Allemagne")))  ;
	vbar pop_exporter / response=quantity stat=mean datalabel group=pays_exporter;
	xaxis label = "Population exportateur" ;
	yaxis label = "Volume de transaction en moyenne" ; 
	Title "Flux commerciaux en fonction de la population exportateur en terme de volume" ;
run ; 


   		 /*========================================================================*/
	
	 		/*                     	      FIN DU CODE	                       */

		/*========================================================================*/

