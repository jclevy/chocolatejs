Document = require '../../general/locco/document'

describe 'Document', ->
    it 'should create a Document with no input', ->
        expect((new Document) instanceof Document).toBeTruthy()
        expect(typeof (new Document).uuid).toEqual('string')
    it 'should create a Document with a simple input', ->
        doc = new Document 
            uuid: "913ae9b0-e4a1-4de3-b8a3-20d4db3d3481"
            name: "Livre"
            matter: [
                {
                    uuid: "46479fe8-499f-4308-88ad-9489f1a44bb2"
                    name: "Titre"
                    data: "La Genèse"
                }
            ]

        expect(doc.uuid).toEqual("913ae9b0-e4a1-4de3-b8a3-20d4db3d3481")
