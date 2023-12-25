/**************** Etape préliminaire ********************************/

/*Télécharger la macro SAS a partir de la page suivante: https://www.insee.fr/fr/information/2021906*/
/*choisir la macro en version macro Linux (Red Hat 5) 64 bits compilée en SAS 9.4 */
/*dézipper le fichier et le mettre dans le même dossier que votre espace de travail puis le téléverser sur le serveur dans votre dossier de travail, ici "temperature" */


/************** Lancement de l'analyse ******************************/

libname libmacro "/home/xxxxxxxxx/Temperature"; 

options sasmstore=libmacro mstored;

data temperature; set libmacro.temperature;run;

/*********************************************************************/
/*************************** macro %ACP ******************************/
/*******************************************************************/


%acp(dataact=temperature,
varact=janv fevr mars avri mai juin juil aout sept octo nove dece, varsup=long lati,
id=ville, impress=O, corr=O, vecp=max, ioa=2, iva=2, out=sor, naxer=4, fill=var ind);


/* options de la macro (celles précédées d'une * sont obligatoires):
*DATAACT = nom de table SAS (table SAS contenant les individus actifs)
DATASUP = nom de table SAS (table SAS contenant les individus supplémentaires)
	On peut utiliser des options pour utiliser la même base pour les actifs et suppl, 
	notamment en utilisant le paramètre de poids, cf infra, en affectant un poids=0 aux indiv suppl 
*VARACT = liste de variables (liste des var actives) 
VARSUP = liste de variables (liste des var supplémentaires)
ID = variable (def la variable d'identifiant des indiv actifs)
IDSUP = variables (def la var d'identifiant des individus suppl)
POIDS = variable (def var de pondération, si 0, l'indiv est mis en supplémentaire)
IMPRESS = O ou N (si on veut imprimer le graphique des pertes d'inertie de la proc princomp)
CORR = O ou N (si on veut imprimer stat desc univ et bivariées sur les var actives)
VECP= n ou MAX (nb de vect propres à éditer "MAX" => tous)
IOA = n (nb d'axes sur lesquels avoir l'aide à interprétation des indiv actifs)
IOS = n (nb d'axes sur lesquels avoir l'aide à interprétation des indiv supplémentaires)
IVA = n (nb d'axes sur lesquels avoir l'aide à interprétation des variables actives)
IVS = n (nb d'axes sur lesquels avoir l'aide à interprétation des variables supplémentaires)
PARTIEL = n (dans les tableaux de sorties, permet de ne publier les résultats que pour les n premiers individus les plus contributifs à un axe)
OUT = nom de table SAS (table contenant les résultats de l'analyse: coord, contributions, COS2 et qualité)
NAXER = n (dans la table OUT, précise le nb d'axes sur lesquels récupérer les informations)
FILL = VAR et/ou IND et/ou BARY et/ou ALL (dans la table OUT, précise le type de données récupérées: 
			données relatives aux variables (VAR) ou aux individus (IND)*/

/*********************************************************************/
/************************ proc princomp  ***************************/
/*******************************************************************/
/*on peut ajouter une proc princomp pour avoir ses graph en sorties*/

proc princomp data=temperature n=12 /* nb de CP souhaitées: au début mettre le nb de variables initiales*/
vardef=n
plots(ncomp=2)=(patternprofile pattern(vector) score);
id ville; /*var d'identifiant des indiv*/
var janv fevr mars avri mai juin juil aout sept octo nove dece; /*liste des var actives*/
run;


/*********************************************************************/
/************************ macro %plotACP  ***************************/
/*******************************************************************/
/*autres formats de graphiques permise par les macros de l'INSEE: pas plus beaux...*/
 

title1 "Les variables dans le plan 1-2";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=varsup);
title1 " ";


title2 "Les individus dans le plan 1-2";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=obsact);
title2 " ";

title2 "Les individus & variables dans le plan 1-2";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=obsact varact);
title2 " ";


/*
data=nom de table SAS (table SAS contenant les informations sources)
AXEH=n (choix de l'axe horizontal)
AXEV=n (choix de l'axe vertical)
POINTS=VARACT et/ou VARSUP et/ou OBSACT et/ou OBSSUP (représentations des variables et indiv actif.ves et/ou supplémentaires)





