libname bddchien "/home/xxxxxxxxx/Chiens"; 
/* Intruction globale définissant la bibliothèque permanente 'bddchien' incluant la BDD */

data temporaire_bddchien; set bddchien.chiens; run;
/* data = Début d'étape spécifiant la création d'une nouvelle table temporaire SAS "temporaire_bddchien" dans la bibliothèque temporaire "WORK" (à partir du chemin déclaré dans l'option 'set') */				

												/* Analyse des Correspondances Multiples */
						/* Objectif: réduire la dimension des données en conservant au mieux l’information utile */
/*-------------------------------------------------------------------------------------------------------------------------------------------*/											

														/* Exploration de la base */

/* Tableau de données constitué de 27 observations (lignes) représentants 27 races de chiens 
caractérisées par 7 variables quantitatives (colonnes) et un nombre total de modalités = 23. */

/* 2. Analyse descriptive restituant via un tri à plat les effectifs par modalités des 7 variables qualitatives */
proc freq data=bddchien.chiens; run;

/* Analyse descriptive restituant via un tri croisé les fréquences (conjointes, marginales et conditionnelles) entre les modalités des 7 variables qualitatives (deux à deux) */
proc freq data=bddchien.chiens;
tables taille*(poids velocite intelligence affection agressivite fonction) /* Filtres d'affichage: nofreq norow nocol nopercent */;
tables poids*(velocite intelligence affection agressivite fonction);
tables velocite*(intelligence affection agressivite fonction);
tables intelligence*(affection agressivite fonction);
tables affection*(agressivite fonction);
tables agressivite*(fonction);
run;
/* 2. Résultats: On peut en déduire que certaines modalités reviennent plus fréquemment (cf: nbre d'observations 'Taille++ = 15' , 'Poids+ = 14') 
et on constate une récurrence entres certaines modalités (cf: fréquence conjointe 'Taille++ * Affect- = 44%' 'Taille+ * Agress+ = 33.3%' 'Taille++ * Veloc++ = 33.3%' ) */
/* On pourrait aller plus loin dans cette analyse préliminaire pour mesurer le lien entre les variables (2 à 2) en effectuant des tests de khi-deux d'indépendance */

												/* ACM: Délimitation des axes factoriels */ 
												
/* 3. ACM avec la correction Benzecri sur les 6 variables retenues */
title "'Correction Benzecri' ACM des caractéristiques des races de chiens"; 
proc corresp data=bddchien.chiens mca outc=resACM dimens=6 benzecri;
tables taille poids velocite intelligence affection agressivite;
run;
/* 3. Résultats: L'option Benzecri "ajuste" les résultats de l'inertie en effaçant les "bruits" inutiles: ne prenant en compte que les facteurs > à la moyenne des valeurs propres */ 
/* 4.& 5. Résultats: Avec l'option Benzecri appliquée 2 axes factoriels sont retenus représentants 99% de l'inertie totale:
	-	Axe 1 (CP1) : valeur propre = 0.48
	-	Axe 2 (CP2) : valeur propre = 0.38
*/	
	
												/*ACM: Description des axes*/ 

/* 6. Analyse des tops contributions par modalités sur les 2 axes retenus */
title "Tableau des contributions par modalités - Axe 1";  																							
proc sort data=resACM out=resACMvar_contr1; by descending Contr1 ;run;
proc print data=resACMvar_contr1; var _Name_ Contr1 ;run;
title "Tableau des contributions par modalités - Axe 2";  																							
proc sort data=resACM out=resACMvar_contr2; by descending Contr2 ;run;
proc print data=resACMvar_contr2; var _Name_ Contr2 ;run;																				
/* 6. Résultats des contributions par modalités:
	- CTR moyen : 1/16 = 0,0625
	- Les modalités les plus contributives soient celles ayant les plus fortes variances (> à 0,0625) sur le 1er plan factoriel: 
		-- Axe 1 = Taille++, Taille-, Affec-, Affec+, Veloc++, Poids++
		-- Axe 2 = Poids+, Taille+, Veloc+, Taille-, Poids-, Intell-, Poids++

/* 7. ACM avec la Macro INSEE: 'AIDEACM' afin d'optimiser l'interprétation des résultats par observations */ 
options sasmstore=bddchien mstored;
proc corresp noprint dimens=6 data=bddchien.chiens outc=resACMobs; 
tables nom, taille poids velocite intelligence affection agressivite; 
title "'Macro INSEE' ACM des caractéristiques des races de chiens par observations"; 
%AIDEACM(DATA = resACMobs, DATAINIT = bddchien.chiens, 
 ANALYSE = TABLES, 
 VARACT = taille poids velocite intelligence affection agressivite, 
 IVA = 3, IVS = 3, IOA = 3, IOS = 3);
/* Création d'une nouvelle table avec les données segmentées par observations */
data resACMobs;set resACMobs; if _TYPE_ = "OBS"; run;
/* Analyse des tops contributions par observations sur les 2 axes retenus */
title "Tableau des contributions par observations - Axe 1";  											
proc sort data=resACMobs out=resACMobs_contr1; by descending Contr1 ;run;
proc print data=resACMobs_contr1; var _Name_ Contr1 ;run;
title "Tableau des contributions par observations - Axe 2";  											
proc sort data=resACMobs out=resACMobs_contr2; by descending Contr2 ;run;
proc print data=resACMobs_contr2; var _Name_ Contr2 ;run;	
/* 7. Résultats des contributions par observations:
	- CTR moyen : 1/27 = 0,0327
	- Les observations les plus contributives soient celles ayant les plus fortes variances (> à 0,0327) sur le 1er plan factoriel: 
			-- Axe 1 = Dogue All, Bull-Dog, Teckel, Caniche, Fox-Terrier, Fox-Hound, Doberman, Chihuahua, Pekinois, Mastiff, Bull-Mastif, Cocker
			-- Axe 2 = Basset, Epag. Breton, Dalmatien, Labrador, Mastiff, Boxer, Chihuahua, Pekinois, St-Bernard */

										/* ACM: Représentation graphique des modalités et des observations */ 

/* 7. ACM avec la Macro INSEE: 'AIDEACM' afin d'optimiser l'interprétation des résultats par variables */
options sasmstore=bddchien mstored;
proc corresp noprint dimens=6 data=bddchien.chiens outc=resACMvar_graph; 
tables taille poids velocite intelligence affection agressivite; 
title "'Macro INSEE' ACM des caractéristiques des races de chiens par modalités actives";  
%AIDEACM(DATA = resACMvar_graph, DATAINIT = bddchien.chiens, 
 ANALYSE = tables, 
 VARACT = taille poids velocite intelligence affection agressivite, 
 IVA = 3, IVS = 3, IOA = 3, IOS = 3);

/* 8. Représentation graphique des observations sur le 1er plan factoriel (axe 1 & 2) */												
title "'Macro INSEE' Représentation graphique des observations sur les axes 1 & 2"; 
%PLOTCOR(AXEH=1,AXEV=2,POINTS=OBSACT,DATA=resACMobs); 
/* 8. Résultat: Chaque observation est au barycentre des modalités qui leurs sont spécifiques
				- COS2 moyen = 28 (Axe 1) & COS2 moyen = 22 (Axe 2)
				- Seules les observations avec un COS2 > 28 (Axe 1) & COS2 > 22 (Axe 2) seront commentées (pour rappel plus le nbre se raproche de 100 meilleure sera le représentation)
					-- Les races de chiens "proches" graphiquement sont celles partageant des caractéristiques (modalités) similaires, à l'instar de: 
						.  Bull Dog,Teckel (Axe 1)					
						.  Chihuahua,  Pekinois (Axe 1)
					    .  Fox-Terrier, Caniche (Axe 1)
				    	.  Fox-Hound, Lévrier (Axe 1)
			    		.  Doberman, Pointer (Axe 1)
		    			.  Dalmatien, Labrador, Epagnol Breton, Boxer (Axe 2)

/* 9. Représentation graphique des modalités sur le 1er plan factoriel (axe 1 & 2) */	
title "'Macro INSEE' Représentation graphique des modalités sur les axes 1 & 2"; 
%PLOTCOR(AXEH=1,AXEV=2,POINTS=VARACT,DATA=resACMvar_graph);
/* 9. Résultat: Chaque modalité est au barycentre des individus qui leurs sont spécifiques
				- COS2 moyen = 44 (Axe 1) & COS2 moyen = 28 (Axe 2)
				- Seules les modalités avec un COS2 > 44 (Axe 1) & COS2 > 22 (Axe 2) seront commentées
					-- Les modalités "proches" graphiquement de variables différentes ou communes sont celles des individus avec un profil similaires
						.  Taille-, Poids- : taille moyenne avec poids moyen  (Axe 1)
						.  Affec-, Taille++ : peu affectueux avec très grande taille (Axe 1)
						.  Veloc+, Taille+ : assez rapide avec grande taille  (Axe 2)
											
										/*ACM: Variable et individu supplémentaire*/ 
										
/* 10. Intégration de la variable illustrative "Fonction"*/
/* ACM avec la Macro INSEE: 'AIDEACM' afin d'optimiser l'interprétation des résultats par variables*/
proc corresp noprint dimens=6 data=bddchien.chiens outc=resACMvar_varsup; 
tables taille poids velocite intelligence affection agressivite fonction; 
supplementary fonction; 
weight SUPPLE;  
title "'Macro INSEE' ACM des caractéristiques des races de chiens par modalités actives avec ajout d'une variable illustrative"; 
%AIDEACM(DATA = resACMvar_varsup, DATAINIT = bddchien.chiens, 
 ANALYSE = TABLES, 
 VARACT = taille poids velocite intelligence affection agressivite, 
 VARSUP = fonction, 
 WEIGHT = SUPPLE,
 IVA = 3, IVS = 3, IOA = 3, IOS = 3); 
TITLE2 "'Macro INSEE' Représentation graphique des modalités + variables illustratives sur les axes 1 & 2"; 
%PLOTCOR(AXEH=1,AXEV=2,POINTS=VARACT VARSUP,DATA=resACMvar_varsup); 
/* 10. Résultat:
				- Qualité de le représentation des modalités illustratives (variable 'fonction') :
				 . Chasse : COS2 =  0 (Axe 1) &  0 (Axe 2)
				 . Compagnie :  COS2 = 63 (Axe 1) & 0 (Axe 2)
				 . Utilite :  COS2 =  37 (Axe 1) & 0 (Axe 2)
				 	>> La modalité 'Compagnie' et 'Utilité'' est correctement représentée sur l'Axe 1
				 	-- Les modalités illustratives "proches" graphiquement de variables différentes ou communes sont celles des individus avec un profil similaires
						. Compagnie, Affect+ : proche et affectueux (Axe 1)  
						. Affect-, Utilite : peu affectueux avec aide (Axe 1)*/
