DATA_DIR='eval_data'

# download question-answer eval pairs
mkdir -p $DATA_DIR
if [ ! -f "$DATA_DIR/psgs_w100.tsv.pkl" ]; then
  wget https://dl.fbaipublicfiles.com/dpr/data/retriever/biencoder-nq-dev.json.gz -P $DATA_DIR
  gzip -d $DATA_DIR/biencoder-nq-dev.json.gz
fi

# process question answer pairs
python parse_dpr_relevance_data.py \
    --src_path $DATA_DIR/biencoder-nq-dev.json \
    --evaluation_set $DATA_DIR/biencoder-nq-dev.questions \
    --gold_data_path $DATA_DIR/biencoder-nq-dev.pages

# download wiki_dpr
if [ ! -f "$DATA_DIR/psgs_w100.tsv.pkl" ]; then
  wget https://storage.googleapis.com/huggingface-nlp/datasets/wiki_dpr/psgs_w100.tsv.pkl -P $DATA_DIR
fi

# extract subset of the wiki_dpr dataset
python subset_of_wiki_dpr.py \
    --data_dir $DATA_DIR \
    --subset_size 100

# process the subset of the wiki_dpr dataset
python use_own_knowledge_dataset.py \
    --csv_path $DATA_DIR/psgs_w100_subset.tsv \
    --output_dir $DATA_DIR/ \
    --num_proc 16 \
    --batch_size 64


# run evaluation pipeline
python eval_rag.py \
    --model_name_or_path facebook/rag-sequence-nq \
    --model_type rag_sequence \
    --evaluation_set $DATA_DIR/biencoder-nq-dev.questions \
    --gold_data_path $DATA_DIR/biencoder-nq-dev.pages \
    --predictions_path $DATA_DIR/e2e_preds.txt \
    --index_name custom \
    --index_path $DATA_DIR/my_knowledge_dataset_hnsw_index.faiss \
    --passages_path $DATA_DIR/my_knowledge_dataset \
    --eval_mode e2e \
    --gold_data_mode qa \
    --n_docs 5 \
    --print_predictions \
    --recalculate \
    --print_predictions \
    --print_docs