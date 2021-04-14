//
//  PerlinNoise.swift
//  jizhi_saver
//
//  Created by 谢俊琨 on 2021/4/10.
//

import Foundation

let PERLIN_YWRAPB = 4;
let PERLIN_YWRAP = 1 << PERLIN_YWRAPB;
let PERLIN_ZWRAPB = 8;
let PERLIN_ZWRAP = 1 << PERLIN_ZWRAPB;
let PERLIN_SIZE = 4095;

var first_run = true;
var perlin_octaves = 4; // default to medium smooth
var perlin_amp_falloff = 0.5; // 50% reduction/octave

func scaled_cosine(_ i: Double) -> Double {return  0.5 * (1.0 - cos(i * Double.pi));}

var perlin: [Double] = [Double](repeating: 0, count: PERLIN_SIZE + 1); // will be initialized lazily by noise() or noiseSeed()

func p5noise(_ x: Double, _ y: Double=0.0, _ z: Double=0.0) -> Double{
    var x = x;
    var y = y;
    var z = z;
    
    if first_run {
        for i in 0...PERLIN_SIZE {
            perlin[i] = Double.random(in: 0.0..<1.0)
        }
        first_run = false;
    }
    
    
    if (x < 0) {
        x = -x;
    }
    if (y < 0) {
        y = -y;
    }
    if (z < 0) {
        z = -z;
    }
    
    var xi : Int = Int(floor(x));
    var yi : Int = Int(floor(y));
    var zi : Int = Int(floor(z));
    var xf = x - Double(xi);
    var yf = y - Double(yi);
    var zf = z - Double(zi);
    var rxf : Double, ryf :Double;
    
    var r = 0.0;
    var ampl = 0.5;
    
    var n1:Double, n2:Double, n3:Double;
    
    for o in 0..<perlin_octaves {
        var of = xi + yi<<PERLIN_YWRAPB + zi<<PERLIN_ZWRAPB;
        
        rxf = scaled_cosine(xf);
        ryf = scaled_cosine(yf);
        
        n1 = perlin[of & PERLIN_SIZE];
        n1 += rxf * (perlin[(of + 1) & PERLIN_SIZE] - n1);
        n2 = perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
        n2 += rxf * (perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n2);
        n1 += ryf * (n2 - n1);
        
        of += PERLIN_ZWRAP;
        n2 = perlin[of & PERLIN_SIZE];
        n2 += rxf * (perlin[(of + 1) & PERLIN_SIZE] - n2);
        n3 = perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
        n3 += rxf * (perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n3);
        n2 += ryf * (n3 - n2);
        
        n1 += scaled_cosine(zf) * (n2 - n1);
        
        r += n1 * ampl;
        ampl *= perlin_amp_falloff;
        xi <<= 1;
        xf *= 2;
        yi <<= 1;
        yf *= 2;
        zi <<= 1;
        zf *= 2;
        
        if (xf >= 1.0) {
            xi+=1;
            xf-=1;
        }
        if (yf >= 1.0) {
            yi+=1;
            yf-=1;
        }
        if (zf >= 1.0) {
            zi+=1;
            zf-=1;
        }
    }
    return r;
}

func p5noiseDetail(_ lod: Int, _ falloff:Double) {
  if (lod > 0) {
    perlin_octaves = lod;
  }
  if (falloff > 0) {
    perlin_amp_falloff = falloff;
  }
};

func p5map(n: Double, start1: Double, stop1: Double, start2: Double, stop2: Double, withinBounds:Bool=false) -> Double {
  let newval = (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
  if (!withinBounds) {
    return newval;
  }
  if (start2 < stop2) {
    return max(min(newval, stop2), stop2);
  } else {
    return max(min(newval, start2), stop2);
  }
};
