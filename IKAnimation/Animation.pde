class Animation {
  ArrayList<PVector> frames;

  Animation (String name) {
    frames = new ArrayList<PVector>();
    Load(name);
  }

  Animation () {
    frames = new ArrayList<PVector>();
  }

  void Load (String name) {
    Table table = loadTable(name);
    frames.clear();
    int i=0;
    for (TableRow row : table.rows()) {
      frames.add(new PVector(table.getFloat(i, 0), table.getFloat(i, 1)));
      i++;
    }
  }

  void Display () {
    stroke(0);
    strokeWeight(1);
    for (int i=0; i<frames.size(); i++) {
      PVector point = frames.get(i), nextPoint = frames.get((i + 1) % frames.size());
      line(point.x, point.y, nextPoint.x, nextPoint.y);
    }
    stroke(255, 0, 0);
    strokeWeight(3);
    for (int i=0; i<frames.size(); i++) {
      PVector point = frames.get(i);
      point(point.x, point.y);
    }
  }

  void DisplayCubic (int subDiv) {
    stroke(0);
    strokeWeight(2);
    for (int i=0; i<frames.size(); i++) {
      for (int j=0; j<subDiv; j++) {
        float fac = map(i + map(j, 0, subDiv, 0, 1), 0, frames.size(), 0, 1);
        float nextFac = map(i + map(j + 1, 0, subDiv, 0, 1), 0, frames.size(), 0, 1);
        if (nextFac >= 1) {
          nextFac--;
        }

        PVector point = Follow(fac);
        PVector nextPoint = Follow(nextFac);

        //Point(point);
        line(point.x, point.y, nextPoint.x, nextPoint.y);
      }
    }
  }

  PVector Follow (float f) {
    int lineIndex = int(f * frames.size());
    float lineValue = map(f, lineIndex / (float) frames.size(), (lineIndex + 1) / (float) frames.size(), 0, 1);
    return CubicLerp(frames.get(lineIndex), frames.get((lineIndex + 1) % frames.size()), frames.get((lineIndex - 1 + frames.size()) % frames.size()), frames.get((lineIndex + 2) % frames.size()), lineValue);
  }

  Animation Add (PVector add) {
    for (PVector frame : frames) {
      frame.x += add.x;
      frame.y += add.y;
    }
    return this;
  }

  Animation MultX (float facX) {
    for (PVector frame : frames) {
      frame.x *= facX;
    }
    return this;
  }

  Animation MultY (float facY) {
    for (PVector frame : frames) {
      frame.y *= facY;
    }
    return this;
  }

  Animation Copy () {
    Animation clone = new Animation();
    for (PVector frame : frames) {
      clone.frames.add(frame.copy());
    }
    return clone;
  }

  void Mirror () {
    for (int i=0; i<frames.size()/2; i++) {
      PVector temp = frames.get(0).copy();
      frames.remove(0);
      frames.add(temp);
    }
  }
}
