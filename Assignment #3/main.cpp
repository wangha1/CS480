#include <iostream>
#include <map>
#include <vector>
#include <queue>
#include <string>
#include <sstream>


extern int yylex();

extern std::map<std::string, float> symbols;
extern bool _error;

struct AST {
	int ID;
	std::string* value;
	std::vector<struct AST*> child;
};

extern struct AST* root;




namespace patch
{
	template < typename T > std::string to_string( const T& n )
	{
		std::ostringstream stm ;
		stm << n ;
		return stm.str() ;
	}
}

void printAST(struct AST *root){
	std::queue<struct AST*> _printQueue;
	_printQueue.push(root);
	int j = 0;
	//std::cout << *_printQueue.front()->value << "\n" ;
	while(!_printQueue.empty()){
		AST* temp = _printQueue.front();
		if(_printQueue.front()->value != 0){
			std::cout << *_printQueue.front()->value << "\t" << j <<"\n";
		}
		_printQueue.pop();
		for(int i = 0; i < temp->child.size(); ++i){
			if(temp->child[i]){
				_printQueue.push(temp->child[i]);
			}
		}
		++j;
	}
	return;
}

int getlevelUntil(struct AST *root, std::string* value, int level){
	if(root == NULL){
		return 0;
	}
	if(root->value == value)
		return level;
	for(int i = 0; i< root->child.size(); ++i){
		int downlevel = getlevelUntil(root->child[i], value, level + 1);
		if(downlevel != 0){
			return downlevel;
		}
	}
	
}

int getLevel(struct AST *root, std::string* value){
	return getlevelUntil(root, value, 1);
	
}



void print(struct AST *node, struct AST *root, int preLevel){
	int level = preLevel;
	for(int i = 0; i< node->child.size(); ++i){
		if(node->child[i]->value != 0 && node->value != 0){
			level = getLevel(root, node->child[i]->value);
			std::cout << node->ID <<" -> " << node->child[i]->ID<<";\n"<<node->child[i]->ID<<"[label=\""<< *node->child[i]->value <<"\"];\n" ;
			//std::cout << "n" << patch::to_string(level) <<"_"<< patch::to_string(i)<< "->" << "n" << patch::to_string(level-1)<<"_"<< patch::to_string(i)<<"\n";
		}
		
		print(node->child[i], root, level);
	}
	
}


int main(int argc, char const *argv[]) {
	if (!yylex() && _error == false) {
		//std::cout<<root->value<<"\n";
		//printAST(root);
		std::cout<<"digraph G {\n3[label=\"block\"]" <<";\n";
		print(root, root,2);
		std::cout<<"}" << "\n";
		return 0;
	} else {
		return 1;
	}
}
