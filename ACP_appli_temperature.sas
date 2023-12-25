
/*Création d'une librairie correspondant au dossier ou se trouve la base */
/*retrouver l'adresse avec un clic droit sur la base depuis le panneau "Fichiers et dossiers du serveur"*/
libname lib "/home/xxxxxxxxx/Temperature"; 

/*création d'une base de travail temporaire, dans la work */
data temperature; set lib.temperature;run;


/************************ PARTIE 1***************************************/
/******************** premiers résultats *******************************/

/*obj: statistiques descriptives + graphiques + choix du nombre de VP */


/*proc princomp*/

ods graphics on;/*permet options de représentations graphiques => attention: implique de mettre "ods graphics off;" à la fin*/

proc princomp data=temperature n=12 /* nb de CP souhaitées: au début mettre le nb de variables initiales*/
out=res_ACP_indiv outstat=stat vardef=n
plots(ncomp=2)=(patternprofile pattern(vector) score);
id ville; /*var d'identifiant des indiv*/
var janv fevr mars avri mai juin juil aout sept octo nove dece; /*liste des var actives*/
run;

ods graphics off;

/*l'option "vardef=n" précise le diviseur dans le calcul des variances et écart-types
l'option "out=nomtable" précise nom de table en sortie contenant les infos sur les indiv (indiv en lignes): toutes anciennes var + coordonnées des indiv sur les axes
l'option "outstat=nomtable" nom de table en sortie contenant des infos sur les variables (var en lignes): moyennes, écart-types, nombre d'observations, correlations, valeurs propres et coordonn�es pour chaque vecteur propre "score" */

/*la procédure nous donne :
- les statistiques descriptives univariées (moyennes et écart-type) et bivariées (matrice de corrélation) sur nos variables initiales
- les n valeurs propres, leur inertie, écart à la valeur précédente, % du total et % cumulé avec des graphiques illustratifs
- les coordonnées des variables sur les vecteurs propres */

/*la ligne de commande "plots(ncomp=2)=(matrix patternprofile pattern(vector) score);" précise les graphiques
ncomp précise le nombre d'axes que l'on souhaite mobiliser pour les représentations 
pattern(vector): le cercle des corrélations
patternprofile: graph de synthèse représentant les corrélations entre les variables et les axes
score: le graph des individus donne représentation des villes dans plans factoriel pour toutes combinaisons possibles des n axes demandés
*/



/************************ PARTIE 2***************************************/
/***************** analyse des individus *******************************/
/*************!! A ne faire que si on a peu d'indiv !******************/

/*obj:calculer les coord, les cos2 et les CTR des individus à partir de la base "res_ACP_indiv", la base de sortie de la proc princomp (cf out=res_ACP_indiv)*/

/*NB: dans les tables crées par SAS, les vecteurs de composantes principales (les axes) s'appellent "prinX" (X de 1 à nombre de CP choisies)*/

data res_acp_indiv2;set res_acp_indiv; /*ce programme part de la base "out" créée en sortie de la froc princomp précédente*/
array k{*} prin1-prin12; /******* !! modifier le nombre de CP******/ 
sumprin=uss(of k{*});
COS2_1=100*prin1**2/sumprin;
COS2_2=100*prin2**2/sumprin;
COS2_3=100*prin3**2/sumprin;
CTR_1=100*(Prin1**2/(15*9.58177958));/**** !! modifier le dénominateur=nb obs* val propre*/
CTR_2=100*(Prin2**2/(15*2.27641840));
CTR_3=100*(Prin3**2/(15*0.07001440));
format COS2_1 cos2_2 cos2_3 8.1;
rename Prin1=Coord1 Prin2=Coord2 Prin3=Coord3;
run;

data res_acp_indiv2;set res_acp_indiv2;
format Coord1-Coord3 8.2;* les variables numériques coord1 à coord 3 auront un format max de 8 chiffres avant la virgule et 2 après; 
run;

/* Création d'un tableau de synthèse des infos individus*/
/*ne faire QUE si on a peu d'individus*/
proc print data=res_acp_indiv2;
var ville Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3;
run;

/* sommer les COS2 pour vérifier quels sont les individus plus ou moins bien représentés sur chaque plan factoriel
et ne pas commenter les individus mal représentés sur les plans factoriels*/
data res_acp_indiv2; set res_acp_indiv2;
cos2_1et2=cos2_1+cos2_2;
cos2_1et3=cos2_1+cos2_3;
cos2_2et3=cos2_2+cos2_3;
run;

/* Optionnel!!! */
/*Ordonner les tables de sortes à identifier rapidement les plus hautes CTR */
/*après chaque proc sort, on regarde la table crée*/

proc sort data=res_acp_indiv2 out=tri_ctr1(keep=ville Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3);
by descending CTR_1 ;run;

proc sort data=res_acp_indiv2 out=tri_ctr2 (keep=ville Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3);
by descending CTR_2;run;

proc sort data=res_acp_indiv2 out=tri_ctr3 (keep=ville Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3);
by descending CTR_3;run;



/************************ PARTIE 3 ***************************************/
/***************** analyse des variables ********************************/


/*obj:calculer les coord, les cos2 et les CTR des variables à partir de la base "stat", l'autre (!) base de sortie demandée dans la proc princomp (cf outstat=stat)*/



/*Pour récupérer les coordonnées et les CTR des variables */

/*Récupération de l'info sur les coordonnées des variables sur les axes*/
data contr; set stat; /*ce programme part de la base "outstat" créée en sortie de la proc princomp précédente*/
if _type_='SCORE';/*ne garde que les lignes 'score' qui donne les coord sur les variables*/
run;
proc transpose data=contr out=contr1;run;/*transpose la base de données de telle sorte que les infos en lignes (coordonnées) deviennent les colonnes et que les colonnes (les variables de mois) deviennent les lignes*/

data contr2;set contr1; /* ici les calculs sont faits pour les 3 premières CP : à ajuster! */
CTR_1=100*Prin1**2;
CTR_2=100*Prin2**2;
CTR_3=100*Prin3**2;
keep _name_ CTR_1 CTR_2 CTR_3;
run;

/*Récupération de l'info sur les contribution des variables*/
/*proc factor*/
proc factor data=temperature n=12 /* nb de CP souhaitées*/ outstat=res_ACP_var;
var janv fevr mars avri mai juin juil aout sept octo nove dece; /*liste des var actives*/
run;

/*Récupération de l'info sur la qualité de représentation des variables*/
data calcul; set res_ACP_var; /*ce programme part de la base "outstat" créée en sortie de la proc factor précédente*/ 
if _type_='PATTERN';
run;
proc transpose data=calcul out=calcul1;run;

data calcul2;set calcul1; /* obtenue à partir de l'outstat de la proc factor */
COS2_1=100*factor1**2;
COS2_2=100*factor2**2;
COS2_3=100*factor3**2;
run;

/*mise en commun des infos de coord, ctr et coord des variables*/
data resultat_var;
merge calcul2 contr2;
rename Factor1=Coord1 Factor2=Coord2 Factor3=Coord3;
run;
data resultat_var;
set resultat_var;
format Coord1-Coord3 8.2;
format COS2_1-COS2_3 8.1 CTR_1-CTR_3 8.1;
run;
proc print data=resultat_var;
var _name_ Coord1 cos2_1 CTR_1 Coord2 cos2_2 CTR_2 Coord3 cos2_3 CTR_3;
run;

