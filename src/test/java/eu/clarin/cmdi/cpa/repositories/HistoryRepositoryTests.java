package eu.clarin.cmdi.cpa.repositories;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import eu.clarin.cmdi.cpa.model.History;
import eu.clarin.cmdi.cpa.model.Url;
import eu.clarin.cmdi.cpa.utils.Category;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.LocalDateTime;

@SpringBootTest
class HistoryRepositoryTests extends RepositoryTests {

	@Test
	void save() {
	   
	   History history = new History(uRep.save(new Url("http://www.wowasa.com", "www.wowasa.com", true)), Category.Broken, LocalDateTime.now());
	   
	   hRep.save(history);
	   
	   assertEquals(1, hRep.count());
	}
	
	

}
