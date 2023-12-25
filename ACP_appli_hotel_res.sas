
libname bddhotel "/home/xxxxxxxxx/Hotels"; 
/*Intruction globale définissant la bibliothèque permanente 'libdatahotel' incluant la BDD  */

data temporaire_bddhotel; set bddhotel.hotels; run;
/*data = Début d'étape spécifiant la création d'une nouvelle table temporaire SAS "temporaire_datahotel" dans la bibliothèque temporaire "WORK" (à partir du chemin déclaré dans l'option 'set')*/
				
										/*Analyse en Composantes Principales*/
				/*Objectif: réduire la dimension des données en conservant au mieux l’information utile*/

/*-------------------------------------------------------------------------------------------------------------------------------------------*/											

						/*1. Exploration préliminaire: Sélection des statistiques descriptives*/ 

/* 1.1 Analyse univariée restituant les principaux indicateurs de position (moyenne) et de dispersion (écart-type & étendue) ainsi que le nbre d'observation des 8 variables quantitatives initiales.*/
proc means data=bddhotel.hotels MAXDEC=2; run;
/*proc means = Début d'étape spécifiant la création*/

/* 1.2 Analyse bivariée permettant de mesurer et d'interpréter les liens entres les 7 variables via une matrice des corrélations*/
proc corr data=bddhotel.hotels; var equipement chambre reception restaurant calme transports proprete; run;
/*proc corr = Début d'étape spécifiant la création*/


/*-------------------------------------------------------------------------------------------------------------------------------------------*/

										/* 2. ACP: Délimitation des axes factoriels*/ 

/* 2.1 Détermination des CP depuis la table "Valeurs propres de la matrice de corrélation" ou via le diagramme des valeurs propres (Règle de Cattell) 

* PI: les variables intiales sont centrées-réduites par défaut: on choisit de donner le même poids 1/n à toutes les observations.*/
	
ods graphics on;
/* instruction permettant la gestion des aspects graphiques*/
proc princomp data=bddhotel.hotels
/* princomp = Début de procédure effectuant une ACP des 7 variables initiales affichant dans RESULTATS la table de représentation des individus sur les axes factoriels*/

n=7 
/* n= options spécifiant le nbre de composantes principales (= au nbre de variables initiales soit 7)*/

out=table_acp_obs outstat=table_acp_varcp vardef=n 
/* out = Option créant un jeu de données temporaire (table) des observations avec leurs valeurs d'origine + leurs coord. sur les axes factoriels*/
/* outstat = Option créant un jeu de données temporaire (table) des valeurs par variables initiales et leurs combinaisons linéaires (C.P) sur les axes factoriels:
	-	les statistiques simples (moyennes, écart-types, nombre d'observations) - données d'origine.
	-	Les liens entre variables (matrice de correlations) 
	-	Les inerties par rapport au centre de gravité (valeurs propres)
	-	Leurs coordonnées sur les composantes principales (vecteurs propres)*/
/* vardef= Option spécifiant le diviseur à utiliser dans le calcul des variances et des écarts types (ici le nbr d'observertion)*/

plots(ncomp=3)=(patternprofile pattern(vector) score);
/* plots = options (du plan de projection nommé "caractéristique de la composante") éditant les coordonnées des varaibles initiales dans les composantes principales déterminés*/
/* ncomp =  spécifie le nombre d'axes factoriels déterminés à afficher dans le plan de projection (cf:2.1)*/
/* pattern(vector) = spécifie le tracé du plan de projection en cercle des corrélations*/
/* patternprofile = excecute le tracé en spécifiant les liens entre les variables intiales & les axes factoriels déterminés*/
/* score = spécifie et excecute la projection des variables initiales dans les cercles des corrélations avec les axes factoriels déterminés*/

id nom; 
/*option spécifiant le nom des observations*/

var equipement chambre reception restaurant calme transports proprete; 
/*liste des variables initiales selectionnées (cf: 1.1)*/

run;
ods graphics off;

























/*-------------------------------------------------------------------------------------------------------------------------------------------*/
			
								/* 3. ACP: Analyse du nuage des observations*/


/* 3.1 Détermination pour chaque observations sur les axes factoriels des informations suivantes :
	-	Les coordonnées 
	-	Les contributions à l'inertie totale du nuage
	-	La qualité de représentation
*/ 

data table_acp_obs_coordcosctr;set table_acp_obs; 
array k{*} prin1-prin7;  /*Spécifie le préfixe du nom des 7 composantes principales*/
sumprin=uss(of k{*}); /*Spécifie le somme des variances (inertie totale du nuage) des 7 composantes principales*/
COS2_1=100*prin1**3/sumprin;
COS2_2=100*prin2**3/sumprin;
COS2_3=100*prin3**3/sumprin;
COS2_4=100*prin4**3/sumprin;
COS2_5=100*prin5**3/sumprin;
COS2_6=100*prin6**3/sumprin;
COS2_7=100*prin7**3/sumprin;
/*Calcul de la qualité de représentation des obs sur les 3 axes factoriels*/

CTR_1=100*(Prin1**3/(46*2.31613264));
CTR_2=100*(Prin2**3/(46*2.03498665));
CTR_3=100*(Prin3**3/(46*1.51138929));
CTR_4=100*(Prin4**3/(46*0.49645622));
CTR_5=100*(Prin5**3/(46*0.35520715));
CTR_6=100*(Prin6**3/(46*0.23556259));
CTR_7=100*(Prin7**3/(46*0.05026546));
/*Calcul de la contribution à l'inertie des obs sur les 3 axes factoriels*/

format COS2_1 COS2_2 COS2_3 COS2_4 COS2_5 COS2_6 COS2_7 8.1;
rename Prin1=Coord1 Prin2=Coord2 Prin3=Coord3 Prin4=Coord4 Prin5=Coord5 Prin6=Coord6 Prin7=Coord7;
run;
/*data= Début d'étape spécifiant la création d'un jeu de données temporaire (table) depuis la table temp 'table_acp_obs' les observations avec leurs valeurs d'origine, leurs coordonnées + leurs qualités de représentation (via l'indicateur COS2) 
ainsi que leurs contributions 
à l'inertie totale (via l'indicateur CTR) sur chaque axe factoriel*/

proc print data=table_acp_obs_coordcosctr;
var nom Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3;
run;
/*proc print = Début de procédure affichant la table "table_acp_obsbis" dans RESULTATS avec les informations: coordonnées, les contributions, 
les qualité de représentation et ce pour chaque observations sur les 3 axes factoriels.*/













































/*-------------------------------------------------------------------------------------------------------------------------------------------*/
			
								/* 4. ACP: Analyse des variables initiales*/
								
/* 3.1 (à l'instar du point 3.) Détermination des informations suivantes pour chaque variable sur les axes factoriels:
	-	Les coefficients de corrélation (coordonnées) 
	-	Les contributions à l'inertie totale du nuage
	-	La qualité de représentation
*/ 


data table_acp_cp_coord; set table_acp_varcp;
if _type_='SCORE';
run;
/*data = Début d'étape spécifiant la création d'un jeu de données temporaire (table) depuis la table temp 'table_acp_varcp' conditionnée uniquement avec les scores (lignes avec les coordonnées) des variables initiales pour chaque vecteur propre*/


proc transpose data=table_acp_cp_coord out=table_acp_cp_coord_t;run;
/*proc transpose = Début de procédure réalisant une réorganisation de table, afin de facilité la lecture: 7 variables en ligne & leurs coord (=coef de corrélation) en colonne*/


data table_acp_varcp_coord_t_bis;set table_acp_cp_coord_t;
CTR_1=100*Prin1**3;
CTR_2=100*Prin2**3;
CTR_3=100*Prin3**3;
CTR_4=100*Prin4**3;
CTR_5=100*Prin5**3;
CTR_6=100*Prin6**3;
CTR_7=100*Prin7**3;
keep _name_ CTR_1 CTR_2 CTR_3 CTR_4 CTR_5 CTR_6 CTR_7;
run;
/*data = Début d'étape spécifiant la création d'un jeu de données temporaire (table) depuis la table temp 'table_acp_varcp' des variables initiales avec leurs contributions sur les axes factoriels*/

proc factor data=bddhotel.hotels n=7 outstat=table_acp_cp;
var equipement chambre reception restaurant calme transports proprete;
run;
/*proc factor = Début de procédure effectuant une ACP des 7 variables initiales affichant dans RESULTATS la table de représentation les coordonnées des variables initiales sur les axes factoriels*/
/* n= options spécifiant le nbre de composantes principales (= au nbre de variables initiales soit 7)*/

data table_acp_cp_calcul; set table_acp_cp;
if _type_='PATTERN';
run;
/*proc transpose = Début d'étape spécifiant la création d'un jeu de données temporaire (table) depuis la table temp 'table_acp_cp'*/ 

proc transpose data=table_acp_cp_calcul out=table_acp_cp_calcul_t;run;
/*proc transpose = Début de procédure spécifiant la création d'un jeu de données temporaire (table) depuis la table temp 'table_acp_cp_calcul' en réalisant une réorganisation de table, afin de facilité la lecture: 7 variables en ligne & leurs coord en colonne*/


data table_acp_cp_calcul_t_bis;set table_acp_cp_calcul_t;
COS2_1=100*factor1**2;
COS2_2=100*factor2**2;
COS2_3=100*factor3**2;
COS2_4=100*factor4**2;
COS2_5=100*factor5**2;
COS2_6=100*factor6**2;
COS2_7=100*factor7**2;
run;
/*data = Début d'étape spécifiant la création d'un jeu de données temporaire (table) depuis la table temp 'table_acp_cp' des variables initiales avec leurs qualités de représentation sur les axes factoriels*/

data resultat_var_acp;
merge table_acp_varcp_coordcbis table_acp_cp_calcul_tbis;
rename Factor1=Coord1 Factor2=Coord2 Factor3=Coord3 Factor4=Coord4 Factor5=Coord5 Factor6=Coord6 Factor7=Coord7;
run;
/*data = Début d'étape spécifiant la création d'un jeu de données temporaire (table)*/
/* merge = option permettant d'effectuer une jointure entre les 2 tables, spécifiant les coef de corrélation, les contributions et les qualités de représentation des varaibles initiales sur les axes factoriels*/


proc print data=resultat_acp;
var _name_ Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3 Coord4 cos2_4 CTR_4 Coord5 cos2_5 CTR_5 Coord6 cos2_6 CTR_6 Coord7 cos2_7 CTR_7;
run;
/*proc print = Début de procédure affichant dans RESULTATS la table temp précedente*/ 
