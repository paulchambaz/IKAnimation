
ArrayList<Bone> bones;
int selectedBone;

int DEFAULT = 0, ROTATE = 1, CREATE = 2, GRAB = 3;
int mode;

float rotateAngle;

Bone creatorBone;
PVector createPosition, createTail;

Ground ground;

Animation walkCycleLeft, walkCycleRight;

float t;
float pos;

void setup () {
  size(1600, 900);
  bones = new ArrayList<Bone>();
  selectedBone = 0;

  mode = 0;

  bones.add(new Bone(Center(), new PVector(0, 0))); // 0

  bones.add(new Bone(bones.get(0), new PVector(40, 100))); // 1
  bones.add(new Bone(bones.get(1), new PVector(-40, 100))); // 2
  bones.add(new Bone(bones.get(2), new PVector(40, 0))); // 3

  bones.add(new Bone(PVector.add(Center(), new PVector(0, 200)), new PVector(-10, 0))); // 4
  bones.add(new Bone(PVector.add(Center(), new PVector(200, 0)), new PVector(10, 0))); // 5

  bones.get(2).SetUpIK(bones.get(4), bones.get(5), 2);

  bones.add(new Bone(bones.get(0), new PVector(40, 100))); // 6
  bones.add(new Bone(bones.get(6), new PVector(-40, 100))); // 7
  bones.add(new Bone(bones.get(7), new PVector(40, 0))); // 8

  bones.add(new Bone(PVector.add(Center(), new PVector(0, 200)), new PVector(-10, 0))); // 9
  bones.add(new Bone(PVector.add(Center(), new PVector(200, 0)), new PVector(10, 0))); // 10

  bones.get(7).SetUpIK(bones.get(9), bones.get(10), 2);

  bones.add(new Bone(bones.get(0), new PVector(0, -50))); // 11
  bones.add(new Bone(bones.get(11), new PVector(0, -50))); // 11
  bones.add(new Bone(bones.get(12), new PVector(0, -50))); // 11

  ground = new Ground();

  walkCycleLeft = new Animation("walkCycle.csv");
  walkCycleRight = walkCycleLeft.Copy();
  walkCycleRight.Mirror();

  t = 0;
  pos = 100;
}

void draw () {
  Update();
  Display();
  if (mode == CREATE) {
    Create();
  }
}

void keyPressed () {
  if (key == ' ') {
    save("screenshots/screenshot.png");
    exit();
  }
  if (key == 'r') {
    if (mode != ROTATE) {
      mode = ROTATE;
      rotateAngle = DetermineAngle(Right(), Mouse(), bones.get(selectedBone).root) - bones.get(selectedBone).boneAngle;
    } else {
      mode = DEFAULT;
      rotateAngle = 0;
    }
  } else if (key == 'e') {
    if (mode != CREATE) {
      mode = CREATE;
      creatorBone = bones.get(selectedBone);
      createPosition = Mouse();
    } else {
      bones.add(new Bone(creatorBone, createTail));
      selectedBone = bones.size() - 1;
      mode = DEFAULT;
    }
  } else if (keyCode == DELETE) {
    Delete();
    mode = DEFAULT;
  } else if (key == 'g') {
    if (mode != GRAB) {
      mode = GRAB;
    } else {
      mode = DEFAULT;
    }
  }
}

void mousePressed () {
  if (mode == DEFAULT) {
    SelectBone();
  } else if (mode == CREATE) {
    bones.add(new Bone(creatorBone, createTail));
    selectedBone = bones.size() - 1;
    mode = DEFAULT;
  }
  mode = DEFAULT;
}

void Update () {
  if (mode == ROTATE) {
    bones.get(selectedBone).Rotate(DetermineAngle(Right(), Mouse(), bones.get(selectedBone).root) - rotateAngle);
  } else if (mode == GRAB) {
    Move();
  }
  for (Bone bone : bones) {
    bone.IK();
  }

  for (Bone bone : bones) {
    bone.Update();
  }
}

void Display () {
  background(200);

  Animations();

  ground.Display();

  stroke(0);
  strokeWeight(9);
  for (Bone bone : bones) {
    //stroke(bone.boneColor);
    bone.Display();
  }
  strokeWeight(10);
  stroke(60, 200, 90);
  for (Bone bone : bones.get(selectedBone).child) {
    //bone.Display();
  }
  stroke(200, 60, 60);
  //bones.get(selectedBone).Display();
}

void Animations () {

  float footstepSize = 160, footstepOffset = 0, footstepHeight = 50, playerSpeed = 4, waistHeight = 10;

  float animTime = 2 * footstepSize / playerSpeed;
  t += 1 / animTime;
  if (t > 1) {
    t--;
  }

  pos += playerSpeed;

  if (pos > width) {
    pos -= width;
  }

  float posY = height - 200 + GetGround(pos);

  stroke(255, 0, 0);
  strokeWeight(40);
  //point(pos, posY);

  PVector footBasePos = new PVector(pos - footstepOffset, height - 200);

  bones.get(5).root = PVector.add(bones.get(0).root, new PVector(200, 0));
  Animation cloneWalkCycleLeft = walkCycleLeft.Copy().MultX(footstepSize).MultY(footstepHeight).Add(footBasePos);
  bones.get(4).root = cloneWalkCycleLeft.Follow(t);
  bones.get(4).root.y += GetGround(bones.get(4).root.x);

  bones.get(10).root = PVector.add(bones.get(0).root, new PVector(200, 0));
  Animation cloneWalkCycleRight = walkCycleRight.Copy().MultX(footstepSize).MultY(footstepHeight).Add(footBasePos);
  bones.get(9).root = cloneWalkCycleRight.Follow(t);
  bones.get(9).root.y += GetGround(bones.get(9).root.x);

  if (max(dist(pos, posY - 200 + waistHeight, bones.get(4).root.x, bones.get(4).root.y), dist(pos, posY - 200 + waistHeight, bones.get(9).root.x, bones.get(9).root.y)) < 200) {
    bones.get(0).root = new PVector(pos, posY - 200 + waistHeight);
  } else {
    if (dist(pos, posY - 200 + waistHeight, bones.get(4).root.x, bones.get(4).root.y) > dist(pos, posY - 200 + waistHeight, bones.get(9).root.x, bones.get(9).root.y)) {
      bones.get(0).root = new PVector(pos, bones.get(4).root.y - 200 + waistHeight);
    } else {
      bones.get(0).root = new PVector(pos, bones.get(9).root.y - 200 + waistHeight);
    }
  }


  for (Bone bone : bones) {
    bone.Update();
  }
}

float GetGround (float x) {
  float fac = map(x, 0, width, 0, ground.heightMap.length - 1);
  int index = (int) floor(fac);
  index = (index < 0) ? 0 : (index >= ground.heightMap.length - 1) ? ground.heightMap.length - 2 : index;

  println(index, index + 1);

  float h = Lerp(ground.heightMap[index], ground.heightMap[index + 1], fac - floor(fac)) - height + 200;

  return h;
}

void Move () {
  bones.get(selectedBone).root = Mouse();
  if (bones.get(selectedBone).hasParent()) {
    bones.get(selectedBone).UpdateParent();
  }
}

void Delete () {
  if (selectedBone != 0) {
    int toRemove = selectedBone;
    bones.get(selectedBone).DeleteChild();
    if (bones.get(selectedBone).hasParent()) {
      bones.get(selectedBone).parent.child.remove(bones.get(selectedBone));
      selectedBone = bones.indexOf(bones.get(selectedBone).parent);
    } else {
      selectedBone = 0;
    }
    bones.remove(toRemove);
  } else {
    bones.get(0).DeleteChild();
  }
}

void Create () {
  PVector root = PVector.add(creatorBone.root, creatorBone.Tail());
  createTail = PVector.sub(Mouse(), createPosition);
  stroke(60, 90, 180);
  strokeWeight(8);
  line(root.x, root.y, root.x + createTail.x, root.y + createTail.y);
}

void SelectBone () {
  int minDistForSelect = 200;

  int minIndex = 0;
  float minDist = bones.get(0).Dist(Mouse());
  for (int i=1; i<bones.size(); i++) {
    float dist = bones.get(i).Dist(Mouse());
    if (dist < minDist) {
      minIndex = i;
      minDist = dist;
    }
  }
  if (minDist < minDistForSelect) {
    selectedBone = minIndex;
  }
}

float DetermineAngle (PVector a, PVector b, PVector center) {
  return AngleBetween(a, PVector.sub(b, center));
}

float AngleBetween (PVector a, PVector b) {
  float dir = (a.copy().rotate(HALF_PI).dot(b) > 0) ? 1 : -1;
  return dir * PVector.angleBetween(a, b);
}

PVector Right () {
  return new PVector(1, 0);
}

PVector Mouse () {
  return new PVector(mouseX, mouseY);
}

PVector Center () {
  return new PVector(width/2, height/2);
}

PVector Zero () {
  return new PVector();
}

void Point (PVector a) {
  strokeWeight(10);
  point(a.x, a.y);
}

void Line (PVector a, PVector b) {
  strokeWeight(2);
  line(a.x, a.y, b.x, b.y);
}

void Circle (PVector a, float r) {
  strokeWeight(2);
  noFill();
  ellipse(a.x, a.y, 2 * r, 2 * r);
}

float Lerp (float a, float b, float t) {
  return (1 - t) * a + t * b;
}

PVector CubicLerp (PVector a, PVector b, PVector pA, PVector pB, float t) {
  return new PVector(CubicLerp(a.x, b.x, pA.x, pB.x, t), CubicLerp(a.y, b.y, pA.y, pB.y, t));
}


float CubicLerp (float a, float b, float pA, float pB, float t) {
  float vC = -(-6 * b + 3 * a + 2 * pA + pB)/6;
  float vB = (-2 * a + b + pA)/2;
  float vA = b - a + (9 * a - 9 * b - pA + pB)/6;
  float vD = a;
  return vA * t * t * t + vB * t * t + vC * t + vD;
}
