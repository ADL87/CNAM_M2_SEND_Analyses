libname bddhotel "/home/xxxxxxxxx/CAHHotels"; 
/*Intruction globale définissant la bibliothèque permanente 'libdatahotel' incluant la BDD  */

options sasmstore=libmacro mstored;
data temporaire_bddhotel; set bddhotel.hotels; run;
/*data = Début d'étape spécifiant la création d'une nouvelle table temporaire SAS "temporaire_datahotel" dans la bibliothèque temporaire "WORK" (à partir du chemin déclaré dans l'option 'set')*/
				
										/*Classification ascendante hiérarchique*/
				/*Objectif: définir des classes d'individus homogènes & mettre en évidence les liens hiérarchiques entre groupes d’individus*/

/*-------------------------------------------------------------------------------------------------------------------------------------------*/											

						/*1. Exploration préliminaire: Sélection des statistiques descriptives*/ 

/* 1.1 Analyse univariée restituant les principaux indicateurs de position (moyenne) et de dispersion (écart-type & étendue) ainsi que le nbre d'observation des 8 variables quantitatives initiales.*/
proc means data=bddhotel.hotels MAXDEC=2; run;
/*proc means = Début d'étape spécifiant la création*/

/* 1.2 Analyse bivariée permettant de mesurer et d'interpréter les liens entres les 7 variables via une matrice des corrélations*/
proc corr data=bddhotel.hotels; var equipement chambre reception restaurant calme transports proprete; run;
/*proc corr = Début d'étape spécifiant la création*/

/*-------------------------------------------------------------------------------------------------------------------------------------------*/

												/* 2. CAH: Délimitation du nombre de classes */ 
												
/* 2. Procédure générant une classification ascendante hiérarchique des observations:
		- Permettant de définir la similarité entre individus :
			- En calculant la distance entre individus ici via la distance du χ2 (variables quantitatives)
 		- Permettant de définir la similarité entre groupes d'individus :
			- En mesurant la distance entre groupes d'individus via le saut minimum, le lien complet et la perte d'inertie inter-classe (via le critère de WARD)
 		- Permettant de choisir le nombre de classes retenues en définissant la partition optimale (homogène) entre groupes d'individus :
			- En mesurant la distance maximale de l'inertie inter-classe afin de différencier les classes (via le critère de WARD) et minimiser 
				l'inertie intra-classe afin de calculer l'inertie totale (via la formule König-Huyguens).*/
				
proc cluster data=bddhotel.hotels method=ward outtree=rescah standard;
var equipement chambre reception restaurant calme transports proprete;
id nom;
run;
/* Sortie complémentaire*/
proc sort data=rescah; by _NCL_; run; 
proc gplot data=rescah (where=(_NCL_<10)); plot _SPRSQ_*_NCL_; symbol1 value=dot i=join; 
run;quit;

/* Procédure permettant de sortir une table segmentée par classes et générant un dendrogramme*/
proc tree data=rescah nclusters=4 out=rescah_class; id nom; run;
proc sort data=rescah_class; by nom;run;
proc sort data=bddhotel.hotels; by nom;run;
data rescah_analyse; merge bddhotel.hotels rescah_class;by nom;run;

/* 2. Résultats:
	Dans l'optique de maximiser l'inertie inter-classe:  
		- Passage de 3 à 4 groupes on s'arrête après 0.1473, 
		- Nombre de classes = 4.
	Le niveau d’inertie interclasse= 49,1% > 33% (valeur propre du 1er axe factoriel de l'ACP)*/


/*3. Analyse des classes selon variable actives afin de caractériser les 2 groupes de classifications*/
proc sort data=rescah_analyse; by cluster; run;
proc means data=rescah_analyse; 
var equipement chambre reception restaurant calme transports proprete; 
by cluster;
run;
proc freq data=rescah_analyse; 
tables cluster*(nom ville);
run;
proc means data=rescah_analyse; 
var prix; 
by cluster;
run;

/* ACP avec la Macro INSEE: 'plotACP' afin d'optimiser l'interprétation des résultats par variables */
%acp(dataact=rescah_analyse,
varact=equipement chambre reception restaurant calme transports proprete,
id=nom, impress=O, corr=O, vecp=max, ioa=2, iva=2, classes=clusname, axeclas=2, 
out=sor, naxer=4, fill=var ind bary);
title1 "Les variables dans le plan 1-2";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=obsact obssup);
title1 " ";

/* 3. Résultats:
TBD