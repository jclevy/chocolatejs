_module = window ? module
_module[if _module.exports? then "exports" else "Loremlite"] = lorem = do ->

    thesaurus = ['lorem', 'ipsum', 'dolor', 'sit', 'amet,', 'consectetur', 'adipiscing', 'elit', 'ut', 'aliquam,', 'purus', 'sit', 'amet', 'luctus', 'venenatis,', 'lectus', 'magna', 'fringilla', 'urna,', 'porttitor', 'rhoncus', 'dolor', 'purus', 'non', 'enim', 'praesent', 'elementum', 'facilisis', 'leo,', 'vel', 'fringilla', 'est', 'ullamcorper', 'eget', 'nulla', 'facilisi', 'etiam', 'dignissim', 'diam', 'quis', 'enim', 'lobortis', 'scelerisque', 'fermentum', 'dui', 'faucibus', 'in', 'ornare', 'quam', 'viverra', 'orci', 'sagittis', 'eu', 'volutpat', 'odio', 'facilisis', 'mauris', 'sit', 'amet', 'massa', 'vitae', 'tortor', 'condimentum', 'lacinia', 'quis', 'vel', 'eros', 'donec', 'ac', 'odio', 'tempor', 'orci', 'dapibus', 'ultrices', 'in', 'iaculis', 'nunc', 'sed', 'augue', 'lacus,', 'viverra', 'vitae', 'congue', 'eu,', 'consequat', 'ac', 'felis', 'donec', 'et', 'odio', 'pellentesque', 'diam', 'volutpat', 'commodo', 'sed', 'egestas', 'egestas', 'fringilla', 'phasellus', 'faucibus', 'scelerisque', 'eleifend', 'donec', 'pretium', 'vulputate', 'sapien', 'nec', 'sagittis', 'aliquam', 'malesuada', 'bibendum', 'arcu', 'vitae', 'elementum', 'curabitur', 'vitae', 'nunc', 'sed', 'velit', 'dignissim', 'sodales', 'ut', 'eu', 'sem', 'integer', 'vitae', 'justo', 'eget', 'magna', 'fermentum', 'iaculis', 'eu', 'non', 'diam', 'phasellus', 'vestibulum']

    random = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min

    word = -> lorem.words 1
        
    words = (count=3) ->
        index = lorem.random 0, lorem.thesaurus.length-count-1
        lorem.thesaurus.slice(index, index + count).join(' ').replace(/[\.\,]/g, '')

    sentence = -> lorem.sentences 1
        
    sentences = (count=6) ->
        sentences = []
        for i in [0...count]
          words = lorem.words(lorem.random(5, 10)).split(' ')
          words[0] = words[0].substr(0, 1).toUpperCase() + words[0].substr(1)
          str = words.join(' ')
          sentences.push str
        sentences.join('. ') + '.'
        
    paragraph = -> lorem.paragraphs 1

    paragraphs = (count=3) ->
        paragraphs = []
        for i in [0...count]
          paragraph = lorem.sentences lorem.random(10, 20)
          paragraphs.push paragraph
          
        if count > 1 then paragraphs.join('\n') else paragraphs[0]

    image = (options) ->
        options ?= {}
        if typeof options is 'string'
            options = type:options
            
        if options.type?
            path = ''
            path += '/' + (options.width ? "400")
            path += '/' + (options.height ? "200")
            path += '/' + (options.type ? 'any') #animals,arch,nature,people,tech
            path += '/' + options.color if options.color
            path += '?cache=' + (options.id ? (1+Math.random()).toString().substr(2))
            'https://placeimg.com' + path
        else
            path = ''
            path += '/g' if options.color is 'grayscale'
            path += '/' + (options.width ? "400")
            path += '/' + (options.height ? "200")
            path += if options.id? then "?image=#{options.id}" else '?cache=' + (1+Math.random()).toString().substr(2)
            path += if options.blur then "#{if path.indexOf('?') >= 0 then '&' else '?'}blur" else ''
            path += if options.gravity then "#{if path.indexOf('?') >= 0 then '&' else '?'}gravity=#{options.gravity}" else '' # north, east, south, west, center
            'https://picsum.photos' + path

    face = (gender, options) ->
        if typeof gender isnt 'string' then options = gender ; gender = null
        options ?= {}
        gender ?= options.gender
        gender = 'men' if gender is 'man'
        gender = 'women' if gender is 'woman'
        "https://randomuser.me/api/portraits/#{gender ? (if lorem.random(0,1) is 0 then 'women' else 'men')}/#{options.id ? lorem.random 0, 99}.jpg"
        
    {word, words, sentence, sentences, paragraph, paragraphs, image, face, random, thesaurus}

