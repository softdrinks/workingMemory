% to briefly analyze the data

dataPath = fullfile(pwd,'data');
files = dir(fullfile(dataPath,'*.mat'));
data = cell(size(files));

set(figure(1),'pos',[27 63 1849 892],'Name','Correct Rate');clf;
subplot1 = tight_subplot(length(files),2,[0.08 0.05]);
suptitle('Correct rate');

set(figure(2),'pos',[27 63 1849 892],'Name','Response Time');clf;
subplot2 = tight_subplot(length(files),2,[0.08 0.05]);
suptitle('Response Time');

colorSet = {[0.1 0.9 0.1],[0.3 0.6 0.1],[0.6 0.3 0.1],[0.9 0.1 0.1],[0.1 0.1 0.8]};
markStyle = {'-o','-s','-+','.-'};
for filei = 1:length(files)
    % plot CR
    axes(subplot1(2*filei-1));
    hold on

    data{filei} = load(fullfile(dataPath,files(filei).name));
    if data{filei}.breakFlag
        % check if the block is broked
        continue
    end
    subNameIndex = strfind(files(filei).name,'_');
    subName = files(filei).name(subNameIndex(1)+1:subNameIndex(2)-1);
    title(subName);
    
    trialNum = length(data{filei}.chosenAnswer);
    correct = 0;
    correct_sep = cell(data{filei}.TRIALINFO.maxDifficulty,1);
    trialNum_sep = zeros(data{filei}.TRIALINFO.maxDifficulty,1);
    correctRate_sep = cell(data{filei}.TRIALINFO.maxDifficulty,1);
    level = 2;
    correct_sep{level} = zeros(length(data{filei}.chosenAnswer{1}),1);
    correct_lev = zeros(data{filei}.TRIALINFO.maxDifficulty,1);
    
    for i = 1:length(data{filei}.chosenAnswer)
        if length(data{filei}.correctAnswer{i}) > level
            correctRate_sep{level} = correct_sep{level}./trialNum_sep(level);
            level = level+1;
            correct_sep{level} = zeros(length(data{filei}.chosenAnswer{i}),1);
        end
        for j = 1:length(data{filei}.chosenAnswer{i})
            if data{filei}.chosenAnswer{i}(j) == data{filei}.correctAnswer{i}(j)
                correct_sep{level}(j) = correct_sep{level}(j)+1; % calculate for every choice
            end
        end
        trialNum_sep(level) = trialNum_sep(level)+1;
        if isequal(data{filei}.chosenAnswer{i},data{filei}.correctAnswer{i})
            correct_lev(level) = correct_lev(level)+1;
            correct = correct+1; % calculate for trial
        end
    end
    correctRate_sep{level} = correct_sep{level}./trialNum_sep(level);
    correctRate = correct./trialNum;
    correctRate_lev = correct_lev./trialNum_sep;
    for i = 2:level
        plot(correctRate_sep{i},markStyle{i-1},'color',colorSet{i},'LineWidth',6-i);
    end
    xlabel('Order of graphs');
    ylabel('Correct rate');
    yticks(0:0.2:1);
    yticklabels({'0%','20%','40%','60%','80%','100%'});
    ylim([0,1])
    xticks(1:length(correctRate_sep)+1);
    xticklabels(1:length(correctRate_sep))
    lgd = legend({'level 2','level 3','level 4','level 5'},'Location','northeastoutside');
    title(lgd,['Repetition: ' num2str(data{filei}.TRIALINFO.repetition)]);
    
    axes(subplot1(2*filei));
    hold on
    title(subName);
    xlabel('Difficulty level');
    ylabel('Correct rate');
    
    bar(2:data{filei}.TRIALINFO.maxDifficulty,correctRate_lev(2:end),'b');
    bar(data{filei}.TRIALINFO.maxDifficulty+1,correctRate,'k');
    lgd = legend(['repetition: ' num2str(data{filei}.TRIALINFO.repetition)],'location','northeastoutside');
    lgd.Box = 'off';
    xticks(2:length(correctRate_sep)+1);
    xticklabels({2:length(correctRate_sep) 'overall'})
    yticks(0:0.2:1);
    yticklabels({'0%','20%','40%','60%','80%','100%'});
    
    
    % plot RT
    axes(subplot2(filei*2-1));
    title(subName);
    hold on
    responseT = cell(data{filei}.TRIALINFO.maxDifficulty,1);
    for i = 1:length(data{filei}.reactionTime)
        for j = 1:length(data{filei}.reactionTime{i})
            if j == 1
                responseT{j} = cat(1,responseT{j},data{filei}.reactionTime{i}(j));
            else
                responseT{j} = cat(1,responseT{j},data{filei}.reactionTime{i}(j)-data{filei}.reactionTime{i}(j-1));
            end
        end
    end
    
    reaponseTErrorBar = zeros(size(responseT));
    responseTMean = zeros(size(responseT));
    for i = 1:length(responseT)
        responseTMean(i) = mean(responseT{i});
        reaponseTErrorBar(i) = std(responseT{i})./sqrt(length(responseT{i}));
    end
    bar(responseTMean);
    er = errorbar(1:length(responseT),responseTMean,reaponseTErrorBar,reaponseTErrorBar);
    er.Color = 'k';
    er.LineWidth = 2;
    er.LineStyle = 'none';
    xlabel('Order of graphs');
    ylabel('RT accross the difficulty (s)');
    set(subplot2(filei*2-1),'YTickLabelMode','auto');
    xticks(1:data{filei}.TRIALINFO.maxDifficulty);
    xticklabels({'1st','2nd','3rd','4th','5th','6th','7th'});
    legend(['repetition: ' num2str(data{filei}.TRIALINFO.repetition)],'location','northeast');
    
    axes(subplot2(filei*2));
    title(subName);
    hold on
    responseT_level = cell(data{filei}.TRIALINFO.maxDifficulty-1,1);
    level = 2;
    for i = 1:length(data{filei}.correctAnswer)
        if ~isequal(data{filei}.correctAnswer{i},data{filei}.chosenAnswer{i})
            continue
        end
        if length(data{filei}.correctAnswer{i}) > level
            level = level+1;
        end
        responseT_level{level-1} = cat(1,responseT_level{level-1},data{filei}.reactionTime{i});
    end
    
    meanResT_lev = cell(data{filei}.TRIALINFO.maxDifficulty-1,1);
    errorbarResT_lev = cell(data{filei}.TRIALINFO.maxDifficulty-1,1);
    for i = 1:length(responseT_level)
        meanResT_lev{i} = mean(responseT_level{i},1);
        if size(responseT_level{i},1)>1
            errorbarResT_lev{i} = std(responseT_level{i},1)./size(responseT_level{i},1);
        else
            errorbarResT_lev{i} = zeros(size(responseT_level{i}));
        end
    end
    for i = 1:length(meanResT_lev)
        er = errorbar(1:length(meanResT_lev{i}),meanResT_lev{i},errorbarResT_lev{i});
        er.Color = colorSet{i};
        er.LineWidth = 2;
    end
    xlabel('Order of graphs');
    ylabel('RT (s)');
    set(subplot2(filei*2),'YTickLabelMode','auto');
    xticks(1:data{filei}.TRIALINFO.maxDifficulty);
    xticklabels(1:data{filei}.TRIALINFO.maxDifficulty);
    lgd = legend({'level 2','level 3','level 4','level 5','level 6','level 7'},'Location','southeast');
    title(lgd,'Difficulty level');
end


function [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)

% tight_subplot creates "subplot" axes with adjustable gaps and margins
%
% [ha, pos] = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
%
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins 
%
%  out:  ha     array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   subplot
%        pos    positions of the axes objects
%
%  Example: ha = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Pekka Kumpulainen 21.5.2012   @tut.fi
% Tampere University of Technology / Automation Science and Engineering


if nargin<3; gap = .02; end
if nargin<4 || isempty(marg_h); marg_h = .05; end
if nargin<5; marg_w = .05; end

if numel(gap)==1
    gap = [gap gap];
end
if numel(marg_w)==1
    marg_w = [marg_w marg_w];
end
if numel(marg_h)==1
    marg_h = [marg_h marg_h];
end

axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;

py = 1-marg_h(2)-axh; 

% ha = zeros(Nh*Nw,1);
ii = 0;
for ih = 1:Nh
    px = marg_w(1);
    
    for ix = 1:Nw
        ii = ii+1;
        ha(ii) = axes('Units','normalized', ...
            'Position',[px py axw axh], ...
            'XTickLabel','', ...
            'YTickLabel','');
        px = px+axw+gap(2);
    end
    py = py-axh-gap(1);
end
if nargout > 1
    pos = get(ha,'Position');
end
ha = ha(:);
end
