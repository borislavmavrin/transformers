import pickle
import os
import argparse
import random


def subset_wiki_dpr(data_dir, subset_size):
	psgs = pickle.load(open(os.path.join(data_dir, 'psgs_w100.tsv.pkl'), 'rb'))
	idx_list = [str(i) for i in random.sample(range(0, len(psgs.keys())), subset_size)]
	header = 'title\ttext\n'
	with open(os.path.join(data_dir, 'psgs_w100_subset.tsv'), 'w') as f:
		f.write(header)
		for psg_idx in idx_list:
			psg = psgs[psg_idx]
			f.write('\t'.join(reversed(psg)) + '\n')


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='Subset the wiki_dpr')
	parser.add_argument('--data_dir', help='Path to the wiki_dpr: psgs_w100.tsv.pkl', required=True)
	parser.add_argument('--subset_size', help='Size of the subset', required=True)
	args = vars(parser.parse_args())
	subset_wiki_dpr(args['data_dir'], int(args['subset_size']))
