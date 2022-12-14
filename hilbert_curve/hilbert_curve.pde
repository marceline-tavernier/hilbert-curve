
// Variables
int order = 1;
int N;
int total;

int orderNext;
int NNext;
int totalNext;

int orderBefore;
int NBefore;
int totalBefore;

boolean isRainbow = true;
int rainbow = 1;

PVector[] path;
PVector[] pathNext;
PVector[] pathBefore;
PVector[] pathPrevious;

boolean lerping = false;
boolean animating = false;
boolean lerpingUp = false;
int lerpingCount = 0;
int maxLerping = 10;

/////////////////////////////////////

// Setup
void setup() {

  // Set size to 512x512, framerate to 30 fps and title
  size(512, 512);
  frameRate(30);
  surface.setTitle("The coding train cabana #3 : Hilbert curve");

  // Set the colors to be on the color wheel
  colorMode(HSB, 360, 255, 255);

  // Calculate the paths of the curves
  calculatePaths();
}

// Draw
void draw() {

  // Black background
  background(0);

  // Don't fill the shape, line weight of 1
  noFill();
  strokeWeight(1);

  // Animate if needed
  lerping();

  // Draw the curve with correct color and path (also used when animating)
  for (int i = 1; i < path.length; i++) {

    // Calculate color
    float h = map(i, 0, path.length, 0, 360 * rainbow) % 360;

    // Apply color
    stroke(h, int(isRainbow) * 255, 255);

    // Draw the line in the path
    line(path[i].x, path[i].y, path[i - 1].x, path[i - 1].y);
  }
}

// Detect when a key is released
void keyReleased() {

  // If UP, animate the curve
  if (key == CODED && keyCode == UP) {
    if (!animating) {
      animating = true;
      lerping = true;
      lerpingUp = true;
    }
  }

  // If DOWN, animate the curve
  else if (order > 1 && key == CODED && keyCode == DOWN) {
    if (!animating) {
      lerping = true;
      animating = true;
    }
  }

  // If R, change between rainbow color and white
  else if (key == 'r' || key == 'R') {
    isRainbow = !isRainbow;
  }

  // If M, add a rainbow
  else if (key == 'm' || key == 'M') {
    rainbow++;
  }

  // If L, remove a rainbow
  else if (rainbow > 1 && (key == 'l' || key == 'L')) {
    rainbow--;
  }
}

// Calculate the paths of the curves
void calculatePaths() {

  // Initialize variables for order
  N = int(pow(2, order));
  total = N * N;
  path = new PVector[total * 4];
  pathPrevious = new PVector[total];

  // Initialize variables for order + 1
  orderNext = order + 1;
  NNext = int(pow(2, orderNext));
  totalNext = NNext * NNext;
  pathNext = new PVector[totalNext];

  // Initialize variables for order - 1
  orderBefore = order - 1;
  NBefore = int(pow(2, orderBefore));
  totalBefore = NBefore * NBefore;
  pathBefore = new PVector[totalBefore * 4];

  // Loop through all points in the path of the curve
  for (int i = 0; i < total; i++) {

    // Do it 4 times to prepare for the next curve
    for (int j = 0; j < 4; j++) {

      // Generate point
      path[i * 4 + j] = hilbert(i, order);
    }
  }

  // Dispatch points for the animation to the next curve
  for (int i = 0; i < total; i++) {
    for (int j = 0; j < 4; j++) {
      if (i % 4 == 0) {
        PVector dir = new PVector(path[(i + 1) * 4 + 1].x - path[i * 4 + j].x, path[(i + 1) * 4 + 1].y - path[i * 4 + j].y);
        path[i * 4 + j].add(j * (dir.x / 5), j * (dir.y / 5));
      } else if (i % 4 == 1) {
        if (j == 0) {
          PVector dir = new PVector(path[(i - 1) * 4].x - path[i * 4 + j].x, path[(i - 1) * 4].y - path[i * 4 + j].y);
          path[i * 4 + j].add((dir.x / 5), (dir.y / 5));
        } else {
          PVector dir = new PVector(path[(i + 1) * 4 + 2].x - path[i * 4 + j].x, path[(i + 1) * 4 + 2].y - path[i * 4 + j].y);
          path[i * 4 + j].add((j - 1) * (dir.x / 5), (j - 1) * (dir.y / 5));
        }
      } else if (i % 4 == 2) {
        if (j == 3) {
          PVector dir = new PVector(path[(i + 1) * 4 + 3].x - path[i * 4 + j].x, path[(i + 1) * 4 + 3].y - path[i * 4 + j].y);
          path[i * 4 + j].add((dir.x / 5), (dir.y / 5));
        } else {
          PVector dir = new PVector(path[(i - 1) * 4 + 1].x - path[i * 4 + j].x, path[(i - 1) * 4 + 1].y - path[i * 4 + j].y);
          path[i * 4 + j].add((3 - j - 1) * (dir.x / 5), (3 - j - 1) * (dir.y / 5));
        }
      } else if (i % 4 == 3) {
        PVector dir = new PVector(path[(i - 1) * 4 + 2].x - path[i * 4 + j].x, path[(i - 1) * 4 + 2].y - path[i * 4 + j].y);
        path[i * 4 + j].add((3 - j) * (dir.x / 5), (3 - j) * (dir.y / 5));
      }
    }
  }

  // Loop through all points in the path of the next curve
  for (int i = 0; i < totalNext; i++) {

    // Generate point
    pathNext[i] = hilbert(i, orderNext);
  }

  // Loop through all points in the path of the previous curve
  for (int i = 0; i < totalBefore; i++) {

    // Do it 4 times to prepare for the next curve
    for (int j = 0; j < 4; j++) {

      // Generate point
      pathBefore[i * 4 + j] = hilbert(i, orderBefore);
    }
  }

  // Dispatch points for the animation from the curve
  if (orderBefore != 0) {
    for (int i = 0; i < totalBefore; i++) {
      for (int j = 0; j < 4; j++) {
        if (i % 4 == 0) {
          PVector dir = new PVector(pathBefore[(i + 1) * 4 + 1].x - pathBefore[i * 4 + j].x, pathBefore[(i + 1) * 4 + 1].y - pathBefore[i * 4 + j].y);
          pathBefore[i * 4 + j].add(j * (dir.x / 5), j * (dir.y / 5));
        } else if (i % 4 == 1) {
          if (j == 0) {
            PVector dir = new PVector(pathBefore[(i - 1) * 4].x - pathBefore[i * 4 + j].x, pathBefore[(i - 1) * 4].y - pathBefore[i * 4 + j].y);
            pathBefore[i * 4 + j].add((dir.x / 5), (dir.y / 5));
          } else {
            PVector dir = new PVector(pathBefore[(i + 1) * 4 + 2].x - pathBefore[i * 4 + j].x, pathBefore[(i + 1) * 4 + 2].y - pathBefore[i * 4 + j].y);
            pathBefore[i * 4 + j].add((j - 1) * (dir.x / 5), (j - 1) * (dir.y / 5));
          }
        } else if (i % 4 == 2) {
          if (j == 3) {
            PVector dir = new PVector(pathBefore[(i + 1) * 4 + 3].x - pathBefore[i * 4 + j].x, pathBefore[(i + 1) * 4 + 3].y - pathBefore[i * 4 + j].y);
            pathBefore[i * 4 + j].add((dir.x / 5), (dir.y / 5));
          } else {
            PVector dir = new PVector(pathBefore[(i - 1) * 4 + 1].x - pathBefore[i * 4 + j].x, pathBefore[(i - 1) * 4 + 1].y - pathBefore[i * 4 + j].y);
            pathBefore[i * 4 + j].add((3 - j - 1) * (dir.x / 5), (3 - j - 1) * (dir.y / 5));
          }
        } else if (i % 4 == 3) {
          PVector dir = new PVector(pathBefore[(i - 1) * 4 + 2].x - pathBefore[i * 4 + j].x, pathBefore[(i - 1) * 4 + 2].y - pathBefore[i * 4 + j].y);
          pathBefore[i * 4 + j].add((3 - j) * (dir.x / 5), (3 - j) * (dir.y / 5));
        }
      }
    }
  }

  // Loop through all points in the path of the curve
  for (int i = 0; i < total; i++) {

    // Generate point
    pathPrevious[i] = hilbert(i, order);
  }
}

// The algorithm to create the hilbert curve
PVector hilbert(int i, int order) {

  // Points in first order
  PVector[] points = {
    new PVector(0, 0),
    new PVector(0, 1),
    new PVector(1, 1),
    new PVector(1, 0)
  };

  // Save it
  int index = i & 3;
  PVector v = points[index];

  // Loop through all order
  for (int j = 1; j < order; j++) {

    // Go to the next order
    i = i >>> 2;
    index = i & 3;
    float len = pow(2, j);

    // Rotate and move it according to the order and part of the path
    // If in the top left part, rotate it
    if (index == 0) {
      float temp = v.x;
      v.x = v.y;
      v.y = temp;
    }

    // If int the bottom left part, move it down
    else if (index == 1) {
      v.y += len;
    }

    // If in the bottom right part, move it down and right
    else if (index == 2) {
      v.x += len;
      v.y += len;
    }

    // If in the top right part, rotate it and move it right
    else if (index == 3) {
      float temp = len - 1 - v.x;
      v.x = len - 1 - v.y;
      v.y = temp;
      v.x += len;
    }
  }

  // Scale it and move it according to the order
  v.mult(9 * width / 10 / (pow(2, order) - 1));
  v.add(width / 20, width / 20);

  // Return the correct point
  return v;
}

// To animate between the curve and the next or the previous
void lerping() {

  // If we need to animate
  if (lerping) {

    // And still need to animate
    if (lerpingCount <= maxLerping) {

      // If moving up an order
      if (lerpingUp) {

        // Lerp all points from the curve to the next
        for (int i = 0; i < path.length; i++) {
          path[i].lerp(pathNext[i], map(lerpingCount, 0, 30, 0.05, 1));
        }
      }

      // If moving down an order
      else {

        // Reset the path curve with 4 times less points for the animation
        path = pathPrevious;

        // Lerp all points from the curve to the previous
        for (int i = 0; i < path.length; i++) {
          path[i].lerp(pathBefore[i], map(lerpingCount, 0, 30, 0.05, 1));
        }
      }

      // Move a 'frame' in the animation
      lerpingCount++;
    }

    // When the animation is finished
    else {

      // If we went up an order, change the order and reset the animation up
      if (lerpingUp) {
        order += 1;
        lerpingUp = false;
      }

      // If we went down an order, change the order
      else {
        order -= 1;
      }

      // Calculate the new paths (for up and down too)
      calculatePaths();

      // Reset the 'frames' and animation state
      lerpingCount = 0;
      lerping = false;
      animating = false;
    }
  }
}
