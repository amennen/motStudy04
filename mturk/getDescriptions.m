nstim = 20;
Q1 = 36;
cols = 1:nstim;
cols = Q1 + 9*cols; % these are all the rows in the data table where the responses are
nsub = 54;

% delete rows where there aren't subjects and just hard code that part
t = readtable('~/Downloads/NEWDESC.csv');
allquestions = table2cell(t(3:end,3:end));
firstrow = 5;
for s =1:nstim
    description{s} = allquestions{firstrow,s};
end

% we would want to average over each persons words so it makes sense to
% have matrix type cell thing
% so maybe ask if kiran would average each word in a sentence, then average
% that for whole thing?

stopWords = {'a', 'about', 'above', 'above', 'across', 'after', 'afterwards', 'again', 'against', 'all', 'almost', 'alone', 'along', 'already', 'also','although','always','am','among', 'amongst', 'amoungst', 'amount',  'an', 'and', 'another', 'any','anyhow','anyone','anything','anyway', 'anywhere', 'are', 'around', 'as',  'at', 'back','be','became', 'because','become','becomes', 'becoming', 'been', 'before', 'beforehand', 'behind', 'being', 'below', 'beside', 'besides', 'between', 'beyond', 'bill', 'both', 'bottom','but', 'by', 'call', 'can', 'cannot', 'cant', 'co', 'con', 'could', 'couldnt', 'cry', 'de', 'describe', 'detail', 'do', 'done', 'down', 'due', 'during', 'each', 'eg', 'eight', 'either', 'eleven','else', 'elsewhere', 'empty', 'enough', 'etc', 'even', 'ever', 'every', 'everyone', 'everything', 'everywhere', 'except', 'few', 'fifteen', 'fify', 'fill', 'find', 'fire', 'first', 'five', 'for', 'former', 'formerly', 'forty', 'found', 'four', 'from', 'front', 'full', 'further', 'get', 'give', 'go', 'had', 'has', 'hasnt', 'have', 'he', 'hence', 'her', 'here', 'hereafter', 'hereby', 'herein', 'hereupon', 'hers', 'herself', 'him', 'himself', 'his', 'how', 'however', 'hundred', 'ie', 'if', 'in', 'inc', 'indeed', 'interest', 'into', 'is', 'it', 'its', 'itself', 'keep', 'last', 'latter', 'latterly', 'least', 'less', 'ltd', 'made', 'many', 'may', 'me', 'meanwhile', 'might', 'mill', 'mine', 'more', 'moreover', 'most', 'mostly', 'move', 'much', 'must', 'my', 'myself', 'name', 'namely', 'neither', 'never', 'nevertheless', 'next', 'nine', 'no', 'nobody', 'none', 'noone', 'nor', 'not', 'nothing', 'now', 'nowhere', 'of', 'off', 'often', 'on', 'once', 'one', 'only', 'onto', 'or', 'other', 'others', 'otherwise', 'our', 'ours', 'ourselves', 'out', 'over', 'own','part', 'per', 'perhaps', 'please', 'put', 'rather', 're', 'same', 'see', 'seem', 'seemed', 'seeming', 'seems', 'serious', 'several', 'she', 'should', 'show', 'side', 'since', 'sincere', 'six', 'sixty', 'so', 'some', 'somehow', 'someone', 'something', 'sometime', 'sometimes', 'somewhere', 'still', 'such', 'system', 'take', 'ten', 'than', 'that', 'the', 'their', 'them', 'themselves', 'then', 'thence', 'there', 'thereafter', 'thereby', 'therefore', 'therein', 'thereupon', 'these', 'they', 'thickv', 'thin', 'third', 'this', 'those', 'though', 'three', 'through', 'throughout', 'thru', 'thus', 'to', 'together', 'too', 'top', 'toward', 'towards', 'twelve', 'twenty', 'two', 'un', 'under', 'until', 'up', 'upon', 'us', 'very', 'via', 'was', 'we', 'well', 'were', 'what', 'whatever', 'when', 'whence', 'whenever', 'where', 'whereafter', 'whereas', 'whereby', 'wherein', 'whereupon', 'wherever', 'whether', 'which', 'while', 'whither', 'who', 'whoever', 'whole', 'whom', 'whose', 'why', 'will', 'with', 'within', 'without', 'would', 'yet', 'you', 'your', 'yours', 'yourself', 'yourselves', 'the'};
str_space='\s';
str_caps='[A-Z]';
str_ch='[a-z]';
str_nums='[0-9]';
% for each recall: take each word and average recall vectors
% over all recalls, average those vectors?
stim=1;
sub=1;
recall = cell2mat(allquestions(sub,stim));
% take out punctuation

Lstr1=length(recall)
ind_space=regexp(recall,str_space);
ind_caps=regexp(recall,str_caps);
ind_chrs=regexp(recall,str_ch);
ind_nums=regexp(recall,str_nums);
mask=[ind_space ind_caps ind_chrs ind_nums];
num_str2=1:1:Lstr1;
num_str2(mask)=[];
str3=recall;
str3(num_str2)=[];

% now take lowercase, split into separate words, take out stop words
c = lower(strsplit(str3));
out_str = c(~ismember(c,stopWords));
nwords = length(out_str);

% next step: look each word up and get its vector
% also how to deal with typos/not in dictionary
% maybe have gui pop up if not in, or error asking what it should change it
% to or just skip?