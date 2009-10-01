PIM: Conversion, Validation & Description tools for PREMIS
==========================================================
* convert between PREMIS and PREMIS embedded in METS
* validate PREMIS embedded in METS against [guidelines](http://www.loc.gov/standards/premis/guidelines-premismets.pdf)
* describe and characterize files' formats in PREMIS with extensions schema

Quickstart
----------
    % git clone git://github.com/flazz/pim.git
    % cd pim
    % ruby app.rb

Source
------
[@github](http://github.com/flazz/pim)

Documentation
-------------
[development wiki](http://wiki.github.com/flazz/pim)

Requirements
------------
* ruby 1.8.7 (not tested on anything else)
* cucumber (gem)
* libxml-ruby (gem)
* libxslt-ruby (gem)
* rjb (gem)
* rspec (gem)
* schematron (gem)
* sinatra (gem)

License
-------
To be Determined...

Credits
-------
* [Priscilla Caplan](pcaplan@ufl.edu): requirements & documentation
* [Francesco Lazzarino](flaz@ufl.edu): programming & design
* [Marly Wilson](marly@ufl.edu): programming & design
* [Carol Chou](cchou@ufl.edu): file format description programming
* [Christian von Kleist](cvonkleist@gmail.com): security & design consultation
* [Tennille Herron](therron@ufl.edu): logo
* layout based on sdworkz' [invention](http://www.oswd.org/design/preview/id/3293)
