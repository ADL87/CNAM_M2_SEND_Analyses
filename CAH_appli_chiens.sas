libname bddchien "/home/xxxxxxxxx/Chiens"; 
/* Intruction globale définissant la bibliothèque permanente 'bddchien' incluant la BDD */
options sasmstore=libmacro mstored;
data temporaire_bddchien; set bddchien.chiens; run;
/* data = Début d'étape spécifiant la création d'une nouvelle table temporaire SAS "temporaire_bddchien" dans la bibliothèque temporaire "WORK" (à partir du chemin déclaré dans l'option 'set') */

												
												/*Classification ascendante hiérarchique*/
				/*Objectif: définir des classes d'individus homogènes & mettre en évidence les liens hiérarchiques entre groupes d’individus*/
					
/*-------------------------------------------------------------------------------------------------------------------------------------------*/											

														/* Exploration de la base */

/* Tableau de données constitué de 27 observations (lignes) représentants 27 races de chiens 
caractérisées par 7 variables quantitatives (colonnes) et un nombre total de modalités = 23. */

/* Analyse descriptive restituant via un tri à plat les effectifs par modalités des 7 variables qualitatives */
proc freq noprint data=bddchien.chiens; run;

/* Analyse descriptive restituant via un tri croisé les fréquences (conjointes, marginales et conditionnelles) entre les modalités des 7 variables qualitatives (deux à deux) */
proc freq noprint data=bddchien.chiens;
tables taille*(poids velocite intelligence affection agressivite fonction) /* Filtres d'affichage: nofreq norow nocol nopercent */;
tables poids*(velocite intelligence affection agressivite fonction);
tables velocite*(intelligence affection agressivite fonction);
tables intelligence*(affection agressivite fonction);
tables affection*(agressivite fonction);
tables agressivite*(fonction);
run;
/* Résultats: On peut en déduire que certaines modalités reviennent plus fréquemment (cf: nbre d'observations 'Taille++ = 15' , 'Poids+ = 14') 
et on constate une récurrence entres certaines modalités (cf: fréquence conjointe 'Taille++ * Affect- = 44%' 'Taille+ * Agress+ = 33.3%' 'Taille++ * Veloc++ = 33.3%' ) */
/* On pourrait aller plus loin dans cette analyse préliminaire pour mesurer le lien entre les variables (2 à 2) en effectuant des tests de khi-deux d'indépendance */

													/* ACM: Délimitation des axes factoriels */ 

/* ACM avec la correction Benzecri sur les 6 variables retenues */
proc corresp noprint data=bddchien.chiens MCA outc=resACMtab dimens=10  benzecri;
tables taille poids velocite intelligence affection agressivite;
run;
											
data chiens_disjonctif; set bddchien.chiens;
taille_G=(taille='Taille++');
taille_M=(taille='Taille+');
taille_P=(taille='Taille-');
poids_G=(poids='Poids++');
poids_M=(poids='Poids+');
poids_P=(poids='Poids-');
veloc_G=(velocite='Veloc++');
veloc_M=(velocite='Veloc+');
veloc_P=(velocite='Veloc-');
intell_G=(intelligence='Intell++');
intell_M=(intelligence='Intell+');
intell_P=(intelligence='Intell-');
affect_G=(affection='Affec+');
affect_P=(affection='Affec-');
agress_G=(agressivite='Agress+');
agress_P=(agressivite='Agress-');
chasse=(fonction='chasse');
utilite=(fonction='utilite');
compagnie=(fonction='compagnie');
run;

data chiens_disjonctif; set chiens_disjonctif;
drop taille poids velocite intelligence agressivite affection fonction;
run;

/* On lance la PROC CORRESP sur le tableau disjonctif complet*/

proc corresp noprint data =chiens_disjonctif dimens=10 outc=resACM_correction;
var taille_G taille_M taille_P poids_G poids_M poids_P veloc_G veloc_M veloc_P intell_G intell_M intell_P affect_G affect_P agress_G agress_P;
id nom;
run; 

/*Observations*/
data resACMobs;set resACM_correction; if _TYPE_ = 'OBS'; run; 


												/* 2. CAH: Délimitation du nombre de classes */ 
												
/* 2. Procédure générant une classification ascendante hiérarchique des observations:
		- Permettant de définir la similarité entre individus :
			- En calculant la distance entre individus ici via la distance du χ2 (variables quantitatives)
 		- Permettant de définir la similarité entre groupes d'individus :
			- En mesurant la distance entre groupes d'individus via le saut minimum, le lien complet et la perte d'inertie inter-classe (via le critère de WARD)
 		- Permettant de choisir le nombre de classes retenues en définissant la partition optimale (homogène) entre groupes d'individus :
			- En mesurant la distance maximale de l'inertie inter-classe afin de différencier les classes (via le critère de WARD) et minimiser 
				l'inertie intra-classe afin de calculer l'inertie totale (via la formule König-Huyguens).*/
				
proc cluster data=resACMobs method=ward outtree=rescah;
var Dim1-Dim10;
id nom;
run;
/* Sortie complémentaire*/
proc sort data=rescah; by _NCL_; run; 
proc gplot data=rescah (where=(_NCL_<10)); plot _SPRSQ_*_NCL_; symbol1 value=dot i=join; 
run;quit;

/* Procédure permettant de sortir une table segmentée par classes et générant un dendrogramme*/
proc tree data=rescah nclusters=4 out=rescah_class; id nom; run;
data rescah_class; set rescah_class (keep=_NAME_ cluster); rename _NAME_=NOM ; run;

/* Merge des variables initiales avec les classes */
proc sort data=bddchien.chiens; by nom; run;
proc sort data=rescah_class; by nom; run;
data res_tdc_class;merge bddchien.chiens rescah_class; by nom;run;
proc sort data=res_tdc_class; by cluster; run;


/* 2. Résultats:
	Dans l'optique de maximiser l'inertie inter-classe:  
		- On s'arrête après le dernier gain d'inertie important soit 0.0474. 
		- Nombre de classes = 4.
	Le niveau d’inertie interclasse= 49,1% > 33% (valeur propre du 1er axe factoriel de l'ACP)*/



/*3. Analyse des classes selon variable actives afin de caractériser les 2 groupes de classifications*/
proc freq data = res_tdc_class;
table (nom taille poids velocite intelligence agressivite affection fonction)*cluster;
run;

/* 3. Résultats:
On retrouve des résultats similaires à ceux de l'AFC, ici les 4 classes sont regroupées selon les races de chiens partageant des caractéristiques (modalités) similaires:
 			- Cluster 1 : Regroupe les races de tailles et de poids moyens, affectueux, intelligents, assez véloces et ayant des fonctions de compagnie et de chasse.
 			- Cluster 2 : Regroupe les races de petites tailles et légers, affectueux, intelligents, non agressifs et ayant une fonction de compagnie.
 			- Cluster 3 : Regroupe les races de grandes tailles et de poids moyens, très véloces, peu affectueux et ayant des fonctions de chasse et d'utilité.
 			- Cluster 4 : Regroupe les races de grandes tailles et lourds, peu véloces, peu affectueux, agressifs et ayant des fonctions d'utilité.


/*4. Réalisez une représentation graphique de cette partition sur les deux premiers axes factoriels de l'ACM réalisée précédemment*/
data resACMobs;set resACM_correction; if _TYPE_ = "OBS"; run; 

proc sort data=rescah_class; by nom;run;
proc sort data=resACMobs; by nom;run;

data resgraph_ACM_CAH; merge resACMobs rescah_class;by nom;run;

/* ACM avec la Macro INSEE: 'grafcol2' afin d'optimiser la visualisation des résultats*/
%macro grafcol2(tab,id,ax1,ax2,h,cat); 
data ann;set &tab;retain xsys ysys '2' hsys '3';  
text=&id;x=dim&ax1;y=dim&ax2; function='label';size=&h; 
if _type_='OBS' then style='swissbi'; 
if _type_='SUPVAR' then style='swissbi'; 
if _type_='VAR' then style='swissb'; 
run; 
proc gplot data=ann gout=&cat; symbol1 height=1.5 value=dot i=none; plot y*x=cluster / annotate=ann href=0 vref=0 frame; 
title h=1 box=2 "Axes &ax1 (&a1) et &ax2 (&a2) "; run;  
title; quit; 
%mend grafcol2; 

%grafcol2(resgraph_ACM_CAH,nom,1,2,1.5,toto); 
		
/*4. Réaliser des classifications sur la base des 5 premiers axes et des 2 premiers axes de l’ACM et comparer les résultats.*/

/* ACM depuis tableau disjonctif complet en retenant 2 axes */
proc corresp noprint DATA =chiens_disjonctif dimens=2 outc=resACM_2;
var taille_G taille_M taille_P poids_G poids_M poids_P veloc_G veloc_M veloc_P intell_G intell_M intell_P affect_G affect_P agress_G agress_P;
id nom;
run;

/* Création d'une nouvelle table avec les données segmentées uniquement par observations */
data resACMobs_2;set resACM_2; if _TYPE_ = 'OBS'; keep nom Dim1-Dim5; run;

/* CAH sur base des 5 axes et sur l'ACM contenant 2 axes */
proc cluster data=resACMobs_2 method=ward outtree=rescah_2;
var Dim1-Dim2;
id nom;
run;

/* CAH sur base des 5 axes et sur l'ACM contenant 2 axes */
proc sort data=rescah_2; by _NCL_; run; 
proc gplot data=rescah_2 (where=(_NCL_<10)); plot _SPRSQ_*_NCL_; symbol1 value=dot i=join; 
run;quit;

/* Procédure permettant de sortir une table segmentée par classes et générant un dendrogramme*/
proc tree DATA=rescah_2 NCLUSTERS=4 OUT=rescah_class_2 H=rsq HOR;run;
data rescah_class_2; set rescah_class_2; rename _NAME_=NOM; run;

data resACMobs2_2;set resACM_2; if _TYPE_ = "OBS"; run; 

proc sort data=rescah_class_2; by nom;run;
proc sort data=resACMobs2_2; by nom;run;

data resgraph_ACM_CAH_2; merge resACMobs2_2 rescah_class_2;by nom;run;

/* ACM avec la Macro INSEE: 'grafcol2' afin d'optimiser la visualisation des résultats*/
%macro grafcol2(tab,id,ax1,ax2,h,cat); 
 
data ann;set &tab;retain xsys ysys '2' hsys '3';  
text=&id;x=dim&ax1;y=dim&ax2; 
function='label';size=&h; if _type_='OBS' then style='swissbi'; 
if _type_='SUPVAR' then style='swissbi'; if _type_='VAR' then style='swissb'; run; 
proc gplot data=ann gout=&cat; symbol1 height=1.5 value=dot i=none; plot y*x=cluster / annotate=ann href=0 vref=0 frame; 
title h=1 box=2 "Axes &ax1 (&a1) et &ax2 (&a2) "; run;  title; quit; 
%mend grafcol2; 
 
%grafcol2(resgraph_ACM_CAH_2,nom,1,2,1.5,toto);