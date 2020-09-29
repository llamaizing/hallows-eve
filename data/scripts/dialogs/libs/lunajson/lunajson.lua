local newdecoder = require 'scripts/dialogs/libs/lunajson/lunajson/decoder'
local newencoder = require 'scripts/dialogs/libs/lunajson/lunajson/encoder'
local sax = require 'scripts/dialogs/libs/lunajson/lunajson/sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}
