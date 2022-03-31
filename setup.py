from setuptools import setup, find_packages

setup(
    name='ScalableParkingCapacityApp',
    version='1.0',
    long_descriptoin=__doc__,
    packages=find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=['Flask', 'aioflask', 'pyodbc', 'Pillow']

)