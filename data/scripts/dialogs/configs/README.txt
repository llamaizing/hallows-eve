Here's how the heirarchy of the dialog system works.

Defualt.lua is always loaded first. This specifies how the dialog box should be displayed
normally.

Each character config can overwrite the default. This is to allow for each character to have
their own dialog box graphics and fonts.

Now here's where the heirarchy gets a little muddy.

We can also specify dialog box information by scene with lower folder attributes overwriting
higher level attributes.
(This scene heirarchy mimics the folder heirarchy found in the languages/<LANGUAGE_YOU_ARE_USING)

Here's an example
say under "languages/en" I have a folder heirarchy that looks like this:
- hero
-- introductions
--- introduces_self

in the "scenes" folder I can recreate that exact same heirarchy. Now each folder in the heirarchy
can contain a config file (it doesn't have to). In each of the these config files you can specify attributes
which will override the folder's above it.

However we are left with a problem. What if I want to override a character's config from the scene. Say one of them
went super saiyan or something and I want to override their dialog box with a new cooler one. That can be done by
first specifying the character in the scene config, then putting all the attributes you wish to override under that name.

Sorry if that's hecka confusing. I think I'll need to add pictures and a video, cause I promise it's simple once you see it.

