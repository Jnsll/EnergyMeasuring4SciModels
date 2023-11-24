
import sys, os

sys.path.append('../models' )#os.path.join(os.path.dirname(__file__), '..', 'models'))

import models


def main():

    models.gas_station_refuel.run()



if __name__ == '__main__':
    # execute only if run as the entry point into the program
    main()