Number.prototype.noExponents= function(){
    var data= String(this).split(/[eE]/);
    if(data.length== 1) return data[0]; 

    var  z= '', sign= this<0? '-':'',
    str= data[0].replace('.', ''),
    mag= Number(data[1])+ 1;

    if(mag<0){
        z= sign + '0.';
        while(mag++) z += '0';
        return z + str.replace(/^\-/,'');
    }
    mag -= str.length;  
    while(mag--) z += '0';
    return str + z;
}
var o =1.5e+16;
var n=1.5e+16 - 1000 - 320/2;
var y = 14999999999999160;
n.noExponents()
console.log(o.noExponents() - y.noExponents());
/*  returned value: (String)
0.000000000465661287307739
*/