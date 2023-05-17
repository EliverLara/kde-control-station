function isDark(color) {

    //color = color.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*(\d+(?:\.\d+)?))?\)$/);

    var r = color.r;
    var g = color.g;
    var b = color.b;

    // HSP (Highly Sensitive Poo) equation from http://alienryderflex.com/hsp.html
    // var hsp = Math.sqrt(
    //     0.299 * (r * r) +
    //     0.587 * (g * g) +
    //     0.114 * (b * b)
    // );

    // Using the HSP value, determine whether the color is light or dark
    console.log("Script de color llamado")


    // return (hsp > 127.5) ? false : true;

    var colorArray = [r, g , b ].map(v => {
        if (v <= 0.03928) {
          return v / 12.92
        }
    
        return Math.pow((v + 0.055) / 1.055, 2.4)
      })
    
      var luminance = 0.2126 * colorArray[0] + 0.7152 * colorArray[1] + 0.0722 * colorArray[2]
    
      return luminance <= 0.179
}