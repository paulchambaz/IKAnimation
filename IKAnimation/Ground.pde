class Ground {
  float[] heightMap;

  Ground () {
    heightMap = new float[100];
    for (int i=0; i<heightMap.length; i++) {
      float index = map(i, 0, heightMap.length, 0, 1);
      heightMap[i] = (noise(index * 3) - .5) *  500;
      heightMap[i] += (noise(index * 10) - .5) * 100;
      //heightMap[i] += (noise(index * 30) - .5) * 30;
    }
    Center(height - 200);
  }

  void Center (float center) {
    float mean = Mean(heightMap);
    for (int i=0; i<heightMap.length; i++) {
      heightMap[i] = heightMap[i] - mean + center;
    }
  }

  float Mean (float[] val) {
    float mean = 0;
    for (int i=0; i<val.length; i++) {
      mean += val[i];
    }
    if (val.length > 0) {
      mean /= val.length;
    }
    return mean;
  }

  void Display () {
    fill(0);
    noStroke();
    beginShape();
    for (int i=0; i<heightMap.length; i++) {
      vertex(i * width / (heightMap.length - 1), heightMap[i]);
    }
    vertex(width, height);
    vertex(0, height);
    endShape(CLOSE);
    //stroke(0);
    //strokeWeight(5);
    //for (int i=0; i<heightMap.length - 1; i++) {
    //  line(i * width / (heightMap.length - 1), heightMap[i], (i + 1) * width / (heightMap.length - 1), heightMap[i + 1]);
    //}
  }
}
