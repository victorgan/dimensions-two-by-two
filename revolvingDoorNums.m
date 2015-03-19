% function tests
%     k = 2;
%     n = 3;
%     i = 2^n - 1; % last graycode
%     revolvingDoorNums = revolvingDoorSequence(k,n)
%     revolvingDoorCode = revolvingDoorCodes(k,n)
%     graycodes = allGraycodes(n)
%     code = graycode(i, n)
% end % function

% >> revolvingDoorSequence(2,3)
%    1     2
%    2     3
%    1     3
function revolvingDoorNums = revolvingDoorSequence(k,n)
    revolvingDoorNums = codesToNumbers(revolvingDoorCodes(k,n));
end % function
function revolvingDoorNums = codesToNumbers(revolvingDoorCode)
    numCodes = size(revolvingDoorCode, 1);
    k = sum(revolvingDoorCode(1,:));
    revolvingDoorNums = zeros(numCodes, k);
    for i = 1:numCodes
        revolvingDoorNums(i,:) = find(revolvingDoorCode(i,:));
    end % for
end % function

% >> revolvingDoorCodes(2,3)
%    1     1     0
%    0     1     1
%    1     0     1
% TODO more efficient algorithm.
% n people, k people in building. Generate all combinations of k people in
% the building while only exchanging one person at at time.
% First link proves filtering graycodes to only include those with k 1's suffices
% http://www.kcats.org/csci/464/doc/knuth/fascicles/fasc3a.pdf
% http://people.math.sfu.ca/~kya17/teaching/math343/16-343.pdf
function revolvingDoorCode = revolvingDoorCodes(k, n)
    graycodes = allGraycodes(n);
    codesWithKEntries = sum(graycodes,2) == k; % filter out rows
    revolvingDoorCode = graycodes(codesWithKEntries,:);

    % Check if there's the correct number (n choose k) of unique codes.
    numCodes = nchoosek(n, k);
    assert( size(revolvingDoorCode, 1) == numCodes);
    assert( size(unique(revolvingDoorCode, 'rows'), 1) == numCodes);
    assert( all(sum(revolvingDoorCode, 2) == k) ); % each row has k 1's
end % function

% Could also implement as finding successive graycodes.
function graycodes = allGraycodes(n)
    % find consecutive graycodes representing 0 to 2^n-1
    numCodes = 2^n - 1;
    graycodes = zeros(numCodes,n);
    for i = 1:numCodes
        graycodes(i,:) = graycode(i, n);
    end % for

    % Check all codes are unique
    assert( size(unique(graycodes, 'rows'), 1) == numCodes)
end % function

% Return the ith out of n graycode in the sequence.
% i: double representing the ith graycode
% n: double number of bits to use (must represent at least i+1 different numbers)
function code = graycode(i, n)
    assert(2^n > i, 'graycode: not enough bits');
    x = floor( (i-1)/2 );
    code = xor( de2bi(x, n), de2bi(i-1, n) ); 
end % function
