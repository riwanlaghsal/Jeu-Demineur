final int INIT = 0;
final int STARTED = 1;
final int OVER = 2;

final int BLOC = 0;
final int EMPTY = 1;
final int FLAG = 2;

int cote;
int bandeau;
int lignes;
int colonnes;
int etat;
int ligneCliquee;
int colonneCliquee;
int mines; // on dit par exemple qu'il y a 10 mines à localiser
long start;
String formattedTime;
float time;
float timeReleased;


int[][] paves;
boolean[][] bombes;
int[][] nb_bombes;

void settings () {
  cote = 20;
  bandeau = 50;
  lignes = 16;
  colonnes = 30;
  size (30*20, (16*20)+bandeau);
  etat = INIT;
}

void setup () {
  background(255);
  init();
}

void draw () {
  display();
  /* drawBlock((colonnes/2)-1, lignes/2, 0, 0);
   // drawBlock((colonnes/2), lignes/2, 0, 0);
   drawBomb((colonnes/2)-1, lignes/2);
   // drawFlag((colonnes/2)-1, lignes/2); je l'ai mis en commentaire pour que maintenant il n'y a le drapeau qui s'affiche à cet endroit seulement avec un clique droit */
  drawTime();
  drawScore();

  println(etat);
}

void drawBlock (float x, float y, float w, float h) {
  pushMatrix ();
  translate (x*cote, (y*cote+50));
  noStroke();
  fill(255);
  rect(0, 0, 19, 2);
  rect(0, 2, 2, 17);
  fill(125);
  rect(2, 18, 18, 2);
  square(1, 19, 1);
  rect(18, 2, 2, 18);
  square(19, 1, 1);
  fill (190);
  square(2, 2, 16);
  popMatrix();
}

void drawBlock2 (float x, float y, float w, float h) {
  pushMatrix ();
  translate (x, y);
  noStroke();
  fill(255);
  rect(0, 0, 19, 2);
  rect(0, 2, 2, 17);
  fill(125);
  rect(2, 18, 18, 2);
  square(1, 19, 1);
  rect(18, 2, 2, 18);
  square(19, 1, 1);
  fill (190);
  square(2, 2, 16);
  popMatrix();
}

void drawBomb (int x, int y) {
  pushMatrix();
  translate(x*cote, (y*cote+50));
  fill(0);
  square(5, 5, 1);
  square(6, 6, 1);
  rect(7, 7, 1, 2);
  rect(6, 8, 1, 5);
  rect(4, 10, 2, 1);
  rect(7, 11, 1, 3);
  square(6, 14, 1);
  square(5, 15, 1);
  rect(8, 12, 5, 3);
  rect(10, 15, 1, 2);
  rect(13, 7, 1, 7);
  rect(14, 8, 1, 5);
  rect(15, 10, 2, 1);
  square(15, 13, 1);
  square(16, 14, 1);
  rect(11, 8, 2, 4);
  square(10, 8, 1);
  square(10, 11, 1);
  square(14, 6, 1);
  square(15, 5, 1);
  rect(8, 6, 5, 2);
  rect(10, 4, 1, 2);
  popMatrix();
}

void drawFlag (int x, int y) {
  pushMatrix();
  translate(x*cote, (y*cote+bandeau));
  fill(0);
  rect(4, 16, 13, 2);
  rect(6, 14, 9, 2);
  rect(10, 4, 1, 10);
  noStroke();
  fill(255, 0, 0);
  rect(9, 4, 1, 5);
  rect(7, 5, 2, 3);
  rect(5, 6, 2, 1);
  popMatrix();
}

void drawHappyFace () {
  pushMatrix();
  float xHappyFace = width/2-10;
  float yHappyFace = bandeau/2-10;
  translate(xHappyFace, yHappyFace);
  fill(255, 255, 0);
  stroke(0);
  ellipse(10, 10, 16, 16);
  fill(0);
  ellipse(7, 7, 2, 2);
  ellipse(13, 7, 2, 2);
  noFill();
  stroke(0);
  arc(10, 10, 8, 6, 0, PI);
  popMatrix();
}

void drawSadFace () {
  pushMatrix();
  float xSadFace = width/2-10;
  float ySadFace = bandeau/2-10;
  translate(xSadFace, ySadFace);
  fill(255, 255, 0);
  stroke(0);
  ellipse(10, 10, 16, 16);
  fill(0);
  line(6, 6, 8, 8);
  line(8, 6, 6, 8);
  line(12, 6, 14, 8);
  line(14, 6, 12, 8);
  noFill();
  stroke(0);
  arc(10, 14, 8, 8, 5*PI/4, 7*PI/4);
  popMatrix();
}

void mouseClicked() {
  ligneCliquee = (mouseY - bandeau) / cote;
  colonneCliquee = mouseX / cote;
  int etat_bloc;
  if (mouseY > bandeau)
    etat_bloc = paves[ligneCliquee][colonneCliquee];
  else
    etat_bloc = EMPTY;
  if (mouseButton == LEFT) {
    if (etat == INIT && mouseY >= bandeau) { // quand on clique en dessous du bandeau, soit l'interface de jeu
      etat = STARTED;
      start = millis();
    } else if (etat == STARTED) {
      if (bombes[ligneCliquee][colonneCliquee]) {
        // si la case contient une bombe, faire passer le jeu de STARTED à OVER
        etat = OVER;
        // arrêter le chrono ici si nécessaire
      } else if (etat_bloc == BLOC) {
        // sinon, faire passer la case de BLOC à EMPTY
        paves[ligneCliquee][colonneCliquee] = EMPTY;
      }
      if (paves[ligneCliquee][colonneCliquee] == EMPTY && nb_bombes[ligneCliquee][colonneCliquee] == 0) {
        decouvre(ligneCliquee, colonneCliquee);
      }
    }
  }
  if (mouseButton == RIGHT && etat == STARTED) {
    if (etat_bloc == BLOC ) {
      paves[ligneCliquee][colonneCliquee] = FLAG;
      mines--;
    } else if (etat_bloc == FLAG) {
      paves[ligneCliquee][colonneCliquee] = BLOC;
      mines++;
    }
  } else if (etat == STARTED) {
    if (mouseX >= width / 2 - 10 && mouseX <= width / 2 + 10 && mouseY >= bandeau / 2 - 10 && mouseY <= bandeau / 2 + 10) { // quand on clique sur le smiley et que l'état passe de started à init
      etat = INIT;
      init();
    }
  } else if (etat == OVER) {
    if (mouseX >= width / 2 - 10 && mouseX <= width / 2 + 10 && mouseY >= bandeau / 2 - 10 && mouseY <= bandeau / 2 + 10) { // quand on clique sur le smiley et que l'état passe de over à init
      etat = INIT;
      init();
    }
  }
}



void display () {
  // couleur de la grille
  background(192);

  //couleur du bandeau
  // fill(192);
  // noStroke();
  // rect(0, 0, width, bandeau);

  drawBlock2(width/2-10, bandeau/3, 20, 20); // bloc du smiley
  if (etat == INIT || etat == STARTED) {
    drawHappyFace();
  } else if (etat == OVER) {
    drawSadFace(); // faire soit un smiley happy ou sad en fonction de l'état
  }
  /*
  if (etat_bloc == BLOC || etat_bloc == FLAG) {
   // drawBlock(colonnes/2 , lignes/2, 0, 0); // faire un bloc avec le clique gauche
   if (etat_bloc == FLAG) {
   drawFlag(colonnes/2, lignes/2); // faire un drapeau sur le bloc avec le clique droit
   } // pour l'instant tout ça se passe à l'endroit du bloc tracé au centre de l'interface de jeu comme demandé dans la consigne, on ne le voit pas car il y a le bloc de la bombe et du drapeau dessus pour l'instant
   }
   */

  PFont mineFont;
  mineFont = createFont("mine-sweeper.ttf", 32);
  // Boucle pour afficher chaque case
  for (int i = 0; i < lignes; i++) {
    for (int j = 0; j < colonnes; j++) {
      int x = j * cote;
      int y = i * cote + bandeau;

      // dessiner le bloc
      if (paves[i][j] != EMPTY) {
        drawBlock2(x, y, cote, cote);

        // afficher le drapeau sur le bloc si l'état est FLAG
        if (paves[i][j] == FLAG) {
          drawFlag(j, i);
        }
      }

      // vérifier s'il y a une bombe dans la case
      if (etat == OVER && bombes[i][j]) {
        drawBomb(j, i); // c'est j, i car dans mouseclicked on a ligneCliquee et colonneCliquee inversée
      } else {
        // s'il n'y a pas de bombe, vérifier le nombre de bombes autour
        int nbBombesAutour = nb_bombes[i][j];
        if (nbBombesAutour > 0 && paves[i][j] == EMPTY) {
          // afficher le nombre de bombes autour avec les couleurs spécifiées
          fill(getColorForNumber(nbBombesAutour));
          textFont(mineFont);
          textAlign(CENTER, CENTER);
          textSize(15);
          text(nbBombesAutour, x + cote / 2, y + cote / 2);
        }
        // sinon, ne rien afficher (nombre de bombes autour est 0)
      }
    }
  }
}

// fonction pour obtenir la couleur en fonction du nombre de bombes autour
color getColorForNumber(int nbBombesAutour) {
  switch (nbBombesAutour) {
  case 1:
    return color(0, 35, 245);
  case 2:
    return color(55, 125, 35);
  case 3:
    return color(235, 50, 35);
  case 4:
    return color(120, 25, 120);
  case 5:
    return color(115, 20, 10);
  case 6:
    return color(55, 125, 125);
  default:
    return color(0);
  }
}


void init() {
  mines = 100;
  paves = new int[lignes][colonnes]; // on initialise paves
  // on initialise tous les blocs à l'état BLOC
  for (int i = 0; i < lignes; i++) {
    for (int j = 0; j < colonnes; j++) {
      paves[i][j] = BLOC;
    }
  }
  // on initialise bombes comme tableau à deux dimensions
  bombes = new boolean[lignes][colonnes];

  // on initialise toutes les valeurs à false
  for (int i = 0; i < lignes; i++) {
    for (int j = 0; j < colonnes; j++) {
      bombes[i][j] = false;
    }
  }
  // on crée aléatoirement une centaine de bombes
  for (int i = 0; i < 100; i++) {
    int ligne = (int) random(lignes);
    int colonne = (int) random(colonnes);

    bombes[ligne][colonne] = true;
  }
  // initialisation du tableau à deux dimensions des bombes autour avec le comptage directement déjà stocké
  nb_bombes = new int[lignes][colonnes];

  for (int i = 0; i < lignes; i++) {
    for (int j = 0; j < colonnes; j++) {
      // on initialise à zéro
      nb_bombes[i][j] = 0;

      // pour parcourir les cases voisines :
      for (int k = -1; k <= 1; k++) {
        for (int l = -1; l <= 1; l++) { // ces boucles imbriquées permettent d'explorer dans le cas du 3x3 les combinaisons possibles des cases autour de la bombe car -1 0 et 1 représentent les positions des cases voisines
          int voisinLigne = i + k;
          int voisinColonne = j + l;

          // verif si le voisin est dans les limites de la grille et contient une bombe
          if (voisinLigne >= 0 && voisinLigne < lignes && voisinColonne >= 0 && voisinColonne < colonnes && bombes[voisinLigne][voisinColonne]) {
            nb_bombes[i][j]++;
          }
        }
      }
    }
  }
}

void drawTime() {
  PFont timeFont;
  timeFont = createFont("DSEG7Classic-Bold.ttf", + 32); // insère la police

  // chronomètre
  fill(0);
  rect(width - 80, 0, 80, 40);
  fill(0);
  fill(90, 10, 10);
  textFont(timeFont);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("888", width - 40, 20);
  if (etat == STARTED) { // le temps s'affiche seulement si la partie commence
    time = (millis() - start) / 1000.0; // calcul du temps écoulé en secondes (on soustrait start à millis pour revenir à 0 au lancement du jeu et on divise par 1000 pour obtenir des secondes)

    if (time >= 1000) {
      time = 999;
    } // fait en sorte que dès que le temps arrive à 1000 secondes, il n'est affiché que 999

    // on formate la valeur du temps de jeu avec les 3 zéros à gauche si nécéssaire
    formattedTime = nf(int(time), 3);

    fill(255, 0, 0);
    text(formattedTime, width - 40, 20); // on affiche le temps formaté et non pas l'initial (c'est à dire celui avec les 3 zéros si nécéssaires)
  }
}

void drawScore() {
  PFont timeFont;
  timeFont = createFont("DSEG7Classic-Bold.ttf", + 32); // j'insère la police au programme

  // rectangle en haut à gauche
  fill(0);
  rect(0, 0, 80, 40);

  // texte pour les mines
  fill(90, 10, 10);
  textFont(timeFont);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("888", 40, 20);
  if (etat == STARTED) {
    // formate la valeur du nombre de mines restantes avec des zéros à gauche si nécessaire
    String formattedMines = nf(int(mines), 3);

    fill(255, 0, 0);
    textSize(28);
    textAlign(CENTER, CENTER);
    text(formattedMines, 40, 20);
  }
  if (etat == OVER) {
  }
}

void decouvre(int x, int y) {
  for (int i = -1; i <= 1; i++)
    for (int j = -1; j <= 1; j++) {
      int blocX = x + i, blocY = y + j;
      if (blocX >= 0 && blocX < colonnes && blocY >= 0 && blocY < lignes) {
        if (bombes[blocX][blocY] == false && paves[blocX][blocY] == BLOC && nb_bombes[blocX][blocY] == 0) {
          paves[blocX][blocY] = EMPTY;
          decouvre(blocX, blocY);
        }
      }
    }
}


/* void decouvre2(int ligne, int colonne) {
 // Vérifier si la case est valide
 if (ligne < 0 || ligne >= lignes || colonne < 0 || colonne >= colonnes) {
 return;
 }
 
 // Vérifier si la case est vide et non découverte
 if (paves[ligne][colonne] == EMPTY) {
 // Obtenir le nombre de bombes et de drapeaux autour de la case
 int nbBombesAutour = nb_bombes[ligne][colonne];
 int nbDrapeauxAutour = countDrapeauxAutour(ligne, colonne);
 
 // Vérifier si le nombre de drapeaux est correct
 if (nbDrapeauxAutour == nbBombesAutour) {
 // Découvrir les cases non encore découvertes et ne portant pas de drapeau
 for (int i = -1; i <= 1; i++) {
 for (int j = -1; j <= 1; j++) {
 int voisinLigne = ligne + i;
 int voisinColonne = colonne + j;
 
 // Vérifier si la case est valide
 if (voisinLigne >= 0 && voisinLigne < lignes && voisinColonne >= 0 && voisinColonne < colonnes) {
 // Vérifier si la case n'a pas de drapeau et n'est pas découverte
 if (paves[voisinLigne][voisinColonne] != FLAG) {
 // Découvrir la case
 paves[voisinLigne][voisinColonne] = BLOC;
 
 // Si la case contient une bombe, passer dans l'état OVER
 if (bombes[voisinLigne][voisinColonne]) {
 etat = OVER;
 }
 
 // Découvrir récursivement les voisins
 decouvre2(voisinLigne, voisinColonne);
 }
 }
 }
 }
 }
 }
 }
 
 // Fonction pour compter le nombre de drapeaux autour de la case spécifiée
 int countDrapeauxAutour(int ligne, int colonne) {
 int count = 0;
 
 for (int i = -1; i <= 1; i++) {
 for (int j = -1; j <= 1; j++) {
 int voisinLigne = ligne + i;
 int voisinColonne = colonne + j;
 
 // Vérifier si la case est valide
 if (voisinLigne >= 0 && voisinLigne < lignes && voisinColonne >= 0 && voisinColonne < colonnes) {
 // Incrémenter le compteur si la case contient un drapeau
 if (paves[voisinLigne][voisinColonne] == FLAG) {
 count++;
 }
 }
 }
 }
 
 return count;
 } */
