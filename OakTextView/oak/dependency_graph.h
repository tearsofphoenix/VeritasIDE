#ifndef DEPENDENCY_GRAPH_H_A254DOQ
#define DEPENDENCY_GRAPH_H_A254DOQ

namespace oak
{
	struct dependency_graph
	{
		// a node is an integer and represents a task to perform
		void add_node (NSUInteger node)
		{
			dependencies.insert(std::make_pair(node, std::set<NSUInteger>()));
		}

		// an edge establishes a dependency from one node (first argument) to another (second argument)
		// e.g. if node RUN depends on node BUILD we call: add_edge(RUN, NODE)
		void add_edge (NSUInteger node, NSUInteger dependsOn)
		{
			dependencies[node].insert(dependsOn);
		}

		// mark a node as “modified” and return all nodes which in effect are then also modified
		std::set<NSUInteger> touch (NSUInteger node) const
		{
			std::set<NSUInteger> res;
			std::vector<NSUInteger> active(1, node);

			while(!active.empty())
			{
				NSUInteger n = active.back();
				res.insert(n);
				active.pop_back();

				iterate(it, dependencies)
				{
					std::set<NSUInteger>::const_iterator node = it->second.find(n);
					if(node == it->second.end() || res.find(it->first) != res.end())
						continue;

					active.push_back(it->first);
				}
			}

			return res;
		}

		// return list of all nodes ordered so that for each node, all it depends on is before that node in this list
		std::vector<NSUInteger> topological_order () const
		{
			std::vector<NSUInteger> res, active;
			iterate(it, dependencies)
			{
				if(it->second.empty())
					active.push_back(it->first);
			}

			std::map< NSUInteger, std::set<NSUInteger> > tmp = dependencies;
			while(!active.empty())
			{
				NSUInteger n = active.back();
				res.push_back(n);
				active.pop_back();

				iterate(it, tmp)
				{
					std::set<NSUInteger>::const_iterator node = it->second.find(n);
					if(node == it->second.end())
						continue;

					it->second.erase(node);
					if(it->second.empty())
						active.push_back(it->first);
				}
			}

			return res;
		}

	private:
		std::map< NSUInteger, std::set<NSUInteger> > dependencies;
	};

} /* oak */ 

#endif /* end of include guard: DEPENDENCY_GRAPH_H_A254DOQ */
