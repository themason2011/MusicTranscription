function result = calcF(precision, recall)
    result = 2*(precision*recall)/(precision+recall);
end