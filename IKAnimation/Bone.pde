class Bone {

  PVector root;
  float boneAngle, boneLength;
  Bone parent;
  ArrayList<Bone> child;

  Bone IKTarget, IKPole;
  int IKChain;

  color boneColor;

  Bone () {
    root = new PVector();
    boneAngle = 0;
    boneLength = 0;
    child = new ArrayList<Bone>();
    IKChain = 0;
    boneColor = color(random(255), random(255), random(255));
  }

  Bone (PVector r, float bA, float bL) {
    root = r.copy();
    boneAngle = bA;
    boneLength = bL;
    child = new ArrayList<Bone>();
    IKChain = 0;
    boneColor = color(random(255), random(255), random(255));
  }

  Bone (PVector r, PVector t) {
    root = r.copy();
    boneAngle = AngleBetween(Right(), t);
    boneLength = t.mag();
    child = new ArrayList<Bone>();
    IKChain = 0;
    boneColor = color(random(255), random(255), random(255));
  }

  Bone (Bone p, float bA, float bL) {
    root = PVector.add(p.root, p.Tail());
    boneAngle = bA;
    boneLength = bL;
    parent = p;
    p.child.add(this);
    child = new ArrayList<Bone>();
    IKChain = 0;
    boneColor = color(random(255), random(255), random(255));
  }

  Bone (Bone p, PVector t) {
    root = PVector.add(p.root, p.Tail());
    parent = p;
    boneAngle = AngleBetween(Right(), t) - p.ParentAngle();
    boneLength = t.mag();
    p.child.add(this);
    child = new ArrayList<Bone>();
    IKChain = 0;
    boneColor = color(random(255), random(255), random(255));
  }

  void SetUpIK (Bone target, Bone pole, int chain) {
    IKTarget = target;
    IKPole = pole;
    IKChain = chain;
  }

  Bone Clone () {
    Bone clone = new Bone();
    clone.root = root.copy();
    clone.boneAngle = boneAngle;
    clone.boneLength = boneLength;
    clone.parent = parent;
    clone.child = child;
    clone.IKTarget = IKTarget;
    clone.IKPole = IKPole;
    clone.IKChain = IKChain;
    return clone;
  }

  void IK () {
    if (IKTarget != null && IKPole != null && IKChain > 0) {
      Bone[] IKBones = new Bone[IKChain];
      Bone IKBone = this.Clone();
      float maxDistance = 0;
      PVector startLocation = new PVector();
      PVector target = IKTarget.root.copy();
      for (int i=0; i<IKChain && hasParent(); i++) {
        startLocation = IKBone.root.copy();
        maxDistance += IKBone.boneLength;
        IKBones[i] = IKBone;
        IKBone = IKBone.parent.Clone();
      }
      float distGoalStart = dist(startLocation.x, startLocation.y, target.x, target.y);
      float currentError = 0;
      int iteration = 0;
      PVector obtained = PVector.add(IKBones[0].root, IKBones[0].Tail());


      for (int i=0; i<IKChain - 1; i++) {
        if (IKBones[i].hasParent()) {
          PVector line = PVector.sub(PVector.add(IKBones[i].root, IKBones[i].Tail()), IKBones[i+1].root.copy()).normalize().rotate(-PI/2);

          stroke(0);
          //Point(IKBones[i+1].root);
          //Line(IKBones[i+1].root, PVector.add(IKBones[i+1].root, PVector.mult(line, 1000)));
          //Line(IKBones[i+1].root, PVector.add(IKBones[i+1].root, PVector.mult(line, -1000)));

          PVector projectedPole = Projected(IKBones[i+1].root.copy(), line, IKPole.root);
          stroke(255, 0, 0);
          //Point(projectedPole);

          PVector currentProjected = Projected(IKBones[i+1].root.copy(), line, IKBones[i].root);
          PVector projectedStart = PVector.sub(IKBones[i+1].root.copy(), currentProjected);
          PVector oppositeProjected = PVector.add(currentProjected, projectedStart.mult(2));
          stroke(0, 255, 0);
          //Point(currentProjected);
          stroke(0, 0, 255);
          //Point(oppositeProjected);

          PVector opposite = PVector.add(oppositeProjected, PVector.sub(IKBones[i].root, currentProjected));
          float distanceCurrent = dist(projectedPole.x, projectedPole.y, currentProjected.x, currentProjected.y);
          float distanceOpposite = dist(projectedPole.x, projectedPole.y, oppositeProjected.x, oppositeProjected.y);

          stroke(0, 255, 0);
          //Circle(projectedPole, distanceCurrent);
          stroke(0, 0, 255);
          //Circle(projectedPole, distanceOpposite);

          if (distanceOpposite < distanceCurrent) {
            // recursively changes all parent

            IKBones[i].MoveOnlyRoot(opposite);
            if (hasParent()) {
              IKBones[i+1].MoveTail(opposite);
            }
          }
        }
      }

      do {

        iteration++;
        stroke(255, 0, 0);
        PVector location = target.copy();
        PVector start = startLocation.copy();
        for (int i=0; i<IKChain; i++) {
          PVector direction = PVector.sub(IKBones[i].root, location).normalize().mult(IKBones[i].boneLength);
          PVector newLocation = PVector.add(location, direction);

          IKBones[i].root = newLocation.copy();
          IKBones[i].MoveTail(location);

          location = newLocation;
        }


        stroke(0, 0, 255);
        location = start;
        for (int i=IKChain - 1; i>=0; i--) {
          PVector direction = PVector.sub(PVector.add(IKBones[i].root, IKBones[i].Tail()), location).normalize().mult(IKBones[i].boneLength);
          PVector newLocation = PVector.add(location, direction);

          IKBones[i].root = location.copy();
          IKBones[i].MoveTail(newLocation);

          location = newLocation;
        }

        obtained = PVector.add(IKBones[0].root, IKBones[0].Tail());

        currentError = dist(target.x, target.y, obtained.x, obtained.y);
      } while ((distGoalStart < maxDistance) && (currentError > 1) && (iteration < 100));

      stroke(255, 255, 0);
      for (int i=0; i<IKChain; i++) {
        //Line(IKBones[i].root, PVector.add(IKBones[i].root, IKBones[i].Tail()));
        //Point(IKBones[i].root);
      }

      Bone moveBone = this;
      stroke(0, 255, 255);
      for (int i=0; i<IKChain && moveBone.hasParent(); i++) {
        moveBone.MoveOnlyRoot(IKBones[i].root);
        moveBone.MoveTail(PVector.add(IKBones[i].root, IKBones[i].Tail()));
        moveBone = moveBone.parent;
        //Line(IKBones[i].root, PVector.add(IKBones[i].root, IKBones[i].Tail()));
        //Point(IKBones[i].root);
      }
    }
  }

  PVector Projected (PVector start, PVector line, PVector point) {
    PVector pointVector = PVector.sub(point, start);
    float projectedLength = line.dot(pointVector);
    return PVector.add(start, PVector.mult(line, projectedLength));
  }

  void MoveOnlyRoot (PVector location) {
    PVector tail = PVector.add(root, Tail());
    root = location.copy();
    MoveTail(tail);
  }


  void UpdateParent () {
    parent.MoveTail(root);
  }


  void Update () {
    if (hasParent()) {
      root = PVector.add(parent.root, parent.Tail());
    }
  }

  void Rotate (float angle) {
    boneAngle = angle;
  }

  void Display () {
    PVector tail = PVector.add(root, Tail());
    line(root.x, root.y, tail.x, tail.y);
  }

  float ParentAngle () {
    if (!hasParent()) {
      return boneAngle;
    } else {
      return boneAngle + parent.ParentAngle();
    }
  } 

  void MoveTail (PVector tail) {
    if (hasParent()) {
      boneAngle = AngleBetween(Right(), PVector.sub(tail, root)) - parent.ParentAngle();
    } else {
      boneAngle = AngleBetween(Right(), PVector.sub(tail, root));
    }
    boneLength = PVector.sub(tail, root).mag();
  }


  PVector Tail () {
    return PVector.fromAngle(ParentAngle()).mult(boneLength);
  }

  boolean hasParent () {
    return (parent != null);
  }

  float Dist (PVector pos) {
    return dist(pos.x, pos.y, root.x + Tail().x / 2, root.y + Tail().y / 2);
  }

  void DeleteChild () {
    for (Bone bone : child) {
      bone.DeleteChild();
      bones.remove(bones.indexOf(bone));
    }
    child.clear();
  }
}
