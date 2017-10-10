// Generated by CoffeeScript 1.12.6
(function() {
  var Document;

  Document = require('../../general/locco/document');

  describe('Document', function() {
    it('should create a Document with no input', function() {
      expect((new Document) instanceof Document).toBeTruthy();
      return expect(typeof (new Document).uuid).toEqual('string');
    });
    return it('should create a Document with a simple input', function() {
      var doc;
      doc = new Document({
        uuid: "913ae9b0-e4a1-4de3-b8a3-20d4db3d3481",
        name: "Livre",
        matter: [
          {
            uuid: "46479fe8-499f-4308-88ad-9489f1a44bb2",
            name: "Titre",
            data: "La Genèse"
          }
        ]
      });
      return expect(doc.uuid).toEqual("913ae9b0-e4a1-4de3-b8a3-20d4db3d3481");
    });
  });

}).call(this);
