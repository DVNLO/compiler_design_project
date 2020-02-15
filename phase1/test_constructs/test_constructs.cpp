#include <bits/stdc++.h>
using namespace std;

struct language_construct
{
	string source_symbol;
	string token;
};

bool valid_counts(unordered_map<string, unsigned> const & keys,
			unsigned const val)
{
	for(auto const key : keys)
	{
		if(key.second != val)
			return false;
	}
	return true;
} 

void count_tokens(string const & file_name, 
			unordered_map<string, unsigned> & counts)
{
	ifstream f(file_name);
	string s;
	while(f >> s)
	{
		if(!counts.count(s))
			cout << "warning : " << s << " not in table\n";
		else
			++counts[s];
	}
}

void print_unused_tokens(unordered_map<string, unsigned> const & counts)
{
	for(auto const count : counts)
	{
		if(!count.second)
			cout << count.first << " is unused.\n";
	}
}

int main(int const argc, char * const * const argv)
{
	unordered_map<string, unsigned> token_counts;
	language_construct lc;
	while(cin >> lc.source_symbol >> lc.token)
	{
		if(token_counts.count(lc.token))
		{
			++token_counts[lc.token];
		}
		else
		{
			token_counts[lc.token] = 0U;
		}
	}
	if(!valid_counts(token_counts, 0))
	{
		puts("error : invalid token_counts found.");
		exit(EXIT_FAILURE);
	}
	vector<string> token_file_names{ "./../tokens/fibonacci.tokens", 
					 "./../tokens/mytest.tokens", 
					 "./../tokens/primes.tokens",
					 "./../tokens/remainder.tokens" };
	for(auto const token_file_name : token_file_names)
	{
		count_tokens(token_file_name, token_counts);
	}
	print_unused_tokens(token_counts); 
}
		
	
