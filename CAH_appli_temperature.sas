/**************** Etape préliminaire ********************************/

/*Télécharger la macro SAS a partir de la page suivante: https://www.insee.fr/fr/information/2021906*/
/*choisir la macro en version macro Linux (Red Hat 5) 64 bits compilée en SAS 9.4 */
/*dézipper le fichier et le mettre dans le même dossier que votre espace de travail puis le téléverser sur le serveur dans votre dossier de travail, ici "temperature" */


/************** Lancement de l'analyse ******************************/

libname libmacro "/home/xxxxxxx/CAHTemperature"; 

options sasmstore=libmacro mstored;

data temperature; set libmacro.temperature;run;



/****************** statistiques descriptives  ************************/

proc means data=temperature;
var janv fevr mars avri mai juin juil aout sept octo nove dece;
run;



/****************** CAH  ************************/

proc cluster data=temperature method=ward outtree=t1 standard;
var janv fevr mars avri mai juin juil aout sept octo nove dece;
id ville;
run;

/*graphique alternatif:*/
/* on trie d'abord la table selon le nombre de classes*/
proc sort data=t1; by _NCL_; run; 
/* on fait un graphique jusque 10 classes*/
proc gplot data=t1 (where=(_NCL_<10)); plot _SPRSQ_*_NCL_; symbol1 value=dot i=join; 
run;quit;

/*analyse des classes  */
/*on crée une table avec : la variable d'identifiant + des variables de classes:"cluster" et "clusname"*/
proc tree data=t1 nclusters=2 out=num_classe; id ville; run;
/*et on fusionne cette table avec la table initiale*/
proc sort data=num_classe; by ville;run;
proc sort data=temperature; by ville;run;
data CAH; merge temperature num_classe;by ville;run;

/*analyse des classes selon variable actives*/
proc sort data=CAH; by cluster; run;
proc means data=CAH; 
var janv fevr mars avri mai juin juil aout sept octo nove dece; 
by cluster;
run;

/*analyse des classes selon variable illustratives*/
proc freq data=CAH; 
tables cluster*(ville region);
run;
/*NB; pour voir quelle ville est dans quelle classe (ici visible sur le graphique uniquement car on a un tout petit échantillon)*/
proc means data=CAH; 
var lati long moye ampl; 
by cluster;
run;

/*projection sur l'ACP: 
on utilise la table CAH pour avoir la variable de classe 
et on ajoute les options classes et axeclas cf ajout var sup quali*/
%acp(dataact=CAH,
varact=janv fevr mars avri mai juin juil aout sept octo nove dece,
id=ville, impress=O, corr=O, vecp=max, ioa=2, iva=2, classes=clusname, axeclas=2, 
out=sor, naxer=4, fill=var ind bary);

title1 "Les variables dans le plan 1-2";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=obsact obssup);
title1 " ";

