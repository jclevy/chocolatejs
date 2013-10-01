// Generated by CoffeeScript 1.6.2
(function() {
  var Data;

  Data = require('../../general/intentware/data');

  describe('Data', function() {
    return describe('Serialization services', function() {
      var o, s;

      o = {
        u: void 0,
        n: null,
        i: 1,
        f: 1.11,
        s: '2',
        b: true,
        d: new Date("Sat Jan 01 2011 00:00:00 GMT+0100")
      };
      s = '';
      it('should stringify an object', function() {
        return expect(s = Data.stringify(o)).toBe("{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,d:new Date(1293836400000)}");
      });
      return it('should parse a string to an object', function() {
        var a;

        a = Data.parse(s);
        expect(a.u).toBe(void 0);
        expect(a.n).toBe(null);
        expect(a.i).toBe(1);
        expect(a.f).toBe(1.11);
        expect(a.s).toBe('2');
        expect(a.b).toBe(true);
        return expect(a.d.valueOf()).toBe(new Date("Sat Jan 01 2011 00:00:00 GMT+0100").valueOf());
      });
    });
  });

}).call(this);
