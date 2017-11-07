from setuptools import setup, find_packages

setup(
	name		= 'pytag',
        version		= '0.1.0',
        package		= 'pytag',
	description	= 'Automated identification of ontological terms in application area specific literature surveys',
        author          = 'Koci Orges',
        email           = 'koci.orges@hotmail.com',
        packages         = find_packages(),
	install_requires = ['bibtexparser', 'inflect'],
        url             = 'https://github.com/KociOrges/pytag',
	entry_points    = {
	  'console_scripts': [
	      'pytag = pytag.pytag:main'
	  ]
	},
)
