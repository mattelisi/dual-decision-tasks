function [id, age, gender, trial, decision, contrast, response, accuracy, RT] = importData(filename)
    T = readtable(filename, 'Delimiter', '\t');
    id = T.id;
    age = T.age;
    gender = T.gender;
    trial = T.trial;
    decision = T.decision;
    contrast = T.contrast;
    response = T.response;
    accuracy = T.accuracy;
    RT = T.RT;
end