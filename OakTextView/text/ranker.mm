#include "ranker.h"

static BOOL is_subset (NSString * needle, NSString * haystack)
{
	NSString *::size_type n = 0, m = 0;
	while(n < needle.size() && m < haystack.size())
	{
		if(needle[n] == haystack[m] || toupper(needle[n]) == haystack[m])
			++n;
		++m;
	}
	D(DBF_Ranker, bug("‘%s’ ⊂ ‘%s’: %s\n", needle.c_str(), haystack.c_str(), BSTR(n == needle.size())););
	return n == needle.size();
}

#ifndef NDEBUG
static void print_matrix (NSUInteger* matrix, NSUInteger n, NSUInteger m, NSString * rowLabel, NSString * colLabel)
{
	fprintf(stderr, "   |");
	for(NSUInteger j = 0; j < m; ++j)
		fprintf(stderr, "%3c", colLabel[j]);
	fprintf(stderr, "\n");

	fprintf(stderr, "---+");
	for(NSUInteger j = 0; j < m; ++j)
		fprintf(stderr, "---");
	fprintf(stderr, "\n");

	for(NSUInteger i = 0; i < n; ++i)
	{
		fprintf(stderr, " %c |", rowLabel[i]);
		for(NSUInteger j = 0; j < m; ++j)
		{
			fprintf(stderr, "%3zu", matrix[i*m + j]);
		}
		fprintf(stderr, "\n");
	}
	fprintf(stderr, "\n");
}
#endif

static double calculate_rank (NSString * lhs, NSString * rhs, std::vector< std::pair<NSUInteger, NSUInteger> >* out)
{
	NSUInteger const n = lhs.size();
	NSUInteger const m = rhs.size();
	NSUInteger matrix[n][m], first[n], last[n];
	BOOL capitals[m];
	bzero(matrix, sizeof(matrix));
	std::fill_n(&first[0], n, m);
	std::fill_n(&last[0],  n, 0);

	BOOL at_bow = true;
	for(NSUInteger j = 0; j < m; ++j)
	{
		char ch = rhs[j];
		capitals[j] = (at_bow && isalnum(ch)) || isupper(ch);
		at_bow = !isalnum(ch) && ch != '\'' && ch != '.';
	}

	for(NSUInteger i = 0; i < n; ++i)
	{
		NSUInteger j = i == 0 ? 0 : first[i-1] + 1;
		for(; j < m; ++j)
		{
			if(tolower(lhs[i]) == tolower(rhs[j]))
			{
				matrix[i][j] = i == 0 || j == 0 ? 1 : matrix[i-1][j-1] + 1;
				first[i]     = MIN(j, first[i]);
				last[i]      = MAX(j+1, last[i]);
			}
		}
	}

	for(ssize_t i = n-1; i > 0; --i)
	{
		NSUInteger bound = last[i]-1;
		if(bound < last[i-1])
		{
			while(first[i-1] < bound && matrix[i-1][bound-1] == 0)
				--bound;
			last[i-1] = bound;
		}
	}

	for(ssize_t i = n-1; i > 0; --i)
	{
		for(NSUInteger j = first[i]; j < last[i]; ++j)
		{
			if(matrix[i][j] && matrix[i-1][j-1])
				matrix[i-1][j-1] = matrix[i][j];
		}
	}

	for(NSUInteger i = 0; i < n; ++i)
	{
		for(NSUInteger j = first[i]; j < last[i]; ++j)
		{
			if(matrix[i][j] > 1 && i+1 < n && j+1 < m)
				matrix[i+1][j+1] = matrix[i][j] - 1;
		}
	}

	D(DBF_Ranker, print_matrix(&matrix[0][0], n, m, lhs, rhs););

	// =========================
	// = Greedy walk of Matrix =
	// =========================

	NSUInteger capitalsTouched = 0; // 0-n
	NSUInteger substrings = 0;      // 1-n
	NSUInteger prefixSize = 0;      // 0-m

	NSUInteger i = 0;
	while(i < n)
	{
		NSUInteger bestJIndex = 0;
		NSUInteger bestJLength = 0;
		for(NSUInteger j = first[i]; j < last[i]; ++j)
		{
			if(matrix[i][j] && capitals[j])
			{
				bestJIndex = j;
				bestJLength = matrix[i][j];

				for(NSUInteger k = j; k < j + bestJLength; ++k)
					capitalsTouched += capitals[k] ? 1 : 0;

				break;
			}
			else if(bestJLength < matrix[i][j])
			{
				bestJIndex = j;
				bestJLength = matrix[i][j];
			}
		}

		if(i == 0)
			prefixSize = bestJIndex;

		NSUInteger len = 0;
		BOOL foundCapital = false;
		do {

			++i; ++len;
			first[i] = MAX(bestJIndex + len, first[i]);
			if(len < bestJLength && n < 4)
			{
				if(capitals[first[i]])
					continue;

				for(NSUInteger j = first[i]; j < last[i] && !foundCapital; ++j)
				{
					if(matrix[i][j] && capitals[j])
						foundCapital = true;
				}
			}

		} while(len < bestJLength && !foundCapital);

		if(out)
			out->push_back(std::make_pair(bestJIndex, bestJIndex + len));

		++substrings;
	}

	// ================================
	// = Calculate rank based on walk =
	// ================================

	NSUInteger totalCapitals = std::count(&capitals[0], &capitals[0] + m, true);
	double score = 0.0;
	double denom = n*(n+1) + 1;
	if(n == capitalsTouched)
	{
		score = (denom - 1) / denom;
	}
	else
	{
		double subtract = substrings * n + (n - capitalsTouched);
		score = (denom - subtract) / denom;
	}
	score += (m - prefixSize) / (double)m / (2*denom);
	score += capitalsTouched / (double)totalCapitals / (4*denom);
	score += n / (double)m / (8*denom);

	D(DBF_Ranker, bug("‘%s’ ⊂ ‘%s’: %.3f\n", lhs.c_str(), rhs.c_str(), score););
	return score;
}

namespace oak
{
	NSString * normalize_filter (NSString * filter)
	{
		NSString * res = "";
		citerate(ch, text::lowercase(filter))
		{
			if(*ch != ' ')
				res += *ch;
		}
		return res;
	}

	double rank (NSString * filter, NSString * candidate, std::vector< std::pair<NSUInteger, NSUInteger> >* out)
	{
		if(filter.empty())
			return 1;
		else if(!is_subset(filter, candidate))
			return 0;
		return calculate_rank(filter, candidate, out);
	}

} /* oak */
