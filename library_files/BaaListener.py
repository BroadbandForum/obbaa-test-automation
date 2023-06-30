"""
BAAListener class is currently not in use
"""

import datetime
import os.path


class BaaListener:
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, filename='baa_test_results.txt'):
        outpath = os.path.join('./robot_test_results', filename)
        self.outfile = open(outpath, 'w')

    def start_suite(self, name, attrs):
        self.outfile.write("%s " % datetime.datetime.now())
        self.outfile.write("Start TestSuite:  %s '%s'\n" % (name, attrs['doc']))

    def start_test(self, name, attrs):
        tags = ' '.join(attrs['tags'])
        self.outfile.write("%s " % datetime.datetime.now())
        #self.outfile.write("- %s '%s' [ %s ] ::\n " % (name, attrs['doc'], tags))
        self.outfile.write("Start TestCase: %s [ %s ] \n" % (name, tags))

    def end_test(self, name, attrs):
        if attrs['status'] == 'PASS':
            self.outfile.write("%s " % datetime.datetime.now())
            self.outfile.write("End TestCase: %s " % name)
            self.outfile.write(": Result: ")
            self.outfile.write('PASS\n')
        else:
            self.outfile.write("%s " % datetime.datetime.now())
            self.outfile.write("End TestCase: %s " % name)
            self.outfile.write(": Result: ")
            self.outfile.write('FAIL: %s\n' % attrs['message'])

    def end_suite(self, name, attrs):
        self.outfile.write("%s " % datetime.datetime.now())
        self.outfile.write("End TestSuite: %s " % name)
        self.outfile.write(": Result: ")
        self.outfile.write('%s\n%s\n' % (attrs['status'], attrs['message']))

    # def start_keyword(self, name, attrs):
    #     self.outfile.write("%s " % datetime.datetime.now())
    #     self.outfile.write("%s " % name)
    #     self.outfile.write("%s \n" % attrs['status'])
    #
    # def end_keyword(self, name, attrs):
    #     self.outfile.write("%s " % datetime.datetime.now())
    #     self.outfile.write("%s " % name)
    #     self.outfile.write("%s \n" % attrs['status'])

    def close(self):
        self.outfile.close()
