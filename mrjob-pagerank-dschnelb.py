# Template for writing MapReduce programs using mrjob
# % python mrjob-pagerank-dschnelb.py graph-1.txt --nodes 4 --beta 0.85 -N 10 -q

from mrjob.job import MRJob
from mrjob.step import MRStep

import sys
orig_stdout = sys.stdout
# print(..., file=orig_stdout)

class MR_program(MRJob):

    def configure_args(self):
        super(MR_program, self).configure_args()
        self.add_passthru_arg('--nodes')    ##  <--- specify which new command line args are used
        self.add_passthru_arg('--beta')    ##  <--- specify which new command line args are used
        self.add_passthru_arg('-N')    ##  <--- specify which new command line args are used

    def mapper_1(self, _, line):
        num_nodes = int(self.options.nodes)
        node, *outlinks = line.split()
        initial_PR = 1/num_nodes # Begin by assuming equal likelihood

        for link in outlinks:
            p_to_link = initial_PR/len(outlinks)
            yield link, p_to_link

        yield node, outlinks

    def reducer_1(self, x, pr_y_by_n_or_nbrs_of_x):
        num_nodes = int(self.options.nodes)
        beta = float(self.options.beta)
        lst = list(pr_y_by_n_or_nbrs_of_x)

        pageranks = []
        for i in lst:
        	if type(i) == list:
        		neighbors = i
        	else:
        		pageranks.append(i)

        PR_x = ((1-beta)/num_nodes) + (beta * sum(pageranks))
        print(x, PR_x, file=orig_stdout)

        for neighbor in neighbors:
            yield neighbor, PR_x/len(neighbors)
        yield x, neighbors

    def reducer_2(self, x, pr_y_by_n_or_nbrs_of_x):
        num_nodes = int(self.options.nodes)
        beta = float(self.options.beta)
        lst = list(pr_y_by_n_or_nbrs_of_x)

        pageranks = []
        for i in lst:
        	if type(i) == list:
        		neighbors = i
        	else:
        		pageranks.append(i)

        PR_x = ((1-beta)/num_nodes) + (beta * sum(pageranks))

        print('"'+x+'"', PR_x, file=orig_stdout)

    def steps(self):
        N = int(self.options.N)
        return [MRStep(mapper=self.mapper_1)] + \
               [MRStep(reducer=self.reducer_1)]*N + \
               [MRStep(reducer=self.reducer_2)]


if __name__ == '__main__':
    # change to match the name of the class
    MR_program.run()
