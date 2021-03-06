package eu.clarin.cmdi.cpa.repositories;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

import eu.clarin.cmdi.cpa.model.Status;
import eu.clarin.cmdi.cpa.model.Url;
import eu.clarin.cmdi.cpa.utils.Category;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.time.LocalDateTime;
import java.util.stream.Stream;

import javax.transaction.Transactional;

@SpringBootTest
class StatusRepositoryTests extends RepositoryTests {

   @Test
   void save() {

      Url url = new Url("http://www.wowasa.com", "www.wowasa.com", true);
      uRep.save(url);

      Status status = new Status(url, Category.Blocked_By_Robots_txt, "", LocalDateTime.now());

      sRep.save(status);

      assertEquals(1, sRep.count());

      // must fail because only one status per URL is allowed
      assertThrows(DataAccessException.class,
            () -> sRep.save(new Status(url, Category.Blocked_By_Robots_txt, "", LocalDateTime.now())));

      // none of the four constructor parameters must be null

      assertThrows(NullPointerException.class,
            () -> sRep.save(new Status(null, Category.Blocked_By_Robots_txt, "", LocalDateTime.now())));
      assertThrows(NullPointerException.class, () -> sRep.save(new Status(url, null, "", LocalDateTime.now())));
      assertThrows(NullPointerException.class,
            () -> sRep.save(new Status(url, Category.Blocked_By_Robots_txt, null, LocalDateTime.now())));
      assertThrows(NullPointerException.class,
            () -> sRep.save(new Status(url, Category.Blocked_By_Robots_txt, "", null)));

   }

   @Test
	@Transactional
	void findAllByCategory() {
	   Url url1 = uRep.save(new Url("http://www.wowasa.com/page1", "www.wowasa.com", true));
	   Url url2 = uRep.save(new Url("http://www.wowasa.com/page2", "www.wowasa.com", true));
	   
	   sRep.save(new Status(url1, Category.Blocked_By_Robots_txt, "", LocalDateTime.now()));
	   sRep.save(new Status(url2, Category.Broken, "", LocalDateTime.now()));
	   
      Page<Status> page = sRep.findAllByCategory(Category.Ok, PageRequest.of(0, 10));     

      assertEquals(0, page.stream().count()); 
      
      page = sRep.findAllByCategory(Category.Blocked_By_Robots_txt, PageRequest.of(0, 10)); 
         
      assertEquals(1, page.stream().count()); 

      
      page = sRep.findAllByCategory(Category.Broken, PageRequest.of(0, 10));

      assertEquals(1, page.stream().count());
    
	}
   
   @Test
   void findByUrlUrl() {
      Url url1 = uRep.save(new Url("http://www.wowasa.com/page1", "www.wowasa.com", true));
      Url url2 = uRep.save(new Url("http://www.wowasa.com/page2", "www.wowasa.com", true));
      
      sRep.save(new Status(url1, Category.Blocked_By_Robots_txt, "", LocalDateTime.now()));
      sRep.save(new Status(url2, Category.Broken, "", LocalDateTime.now()));
      
      assertNotNull(sRep.findByUrlName("http://www.wowasa.com/page1"));
   }
   
   @Transactional
   @Test
   void findAllByUrlUrlIn() {
      
      Url url1 = uRep.save(new Url("http://www.wowasa.com/page1", "www.wowasa.com", true));
      Url url2 = uRep.save(new Url("http://www.wowasa.com/page2", "www.wowasa.com", true));
      
      sRep.save(new Status(url1, Category.Blocked_By_Robots_txt, "", LocalDateTime.now()));
      sRep.save(new Status(url2, Category.Broken, "", LocalDateTime.now()));
      
      try(Stream<Status> stream = sRep.findAllByUrlNameIn("http://www.wowasa.com/page1", "http://www.wowasa.com/page2")){
      
         assertEquals(2, stream.count());
         
      }    
      
      try(Stream<Status> stream = sRep.findAllByUrlNameIn("http://www.wowasa.com/page1", "http://www.wowasa.com/page2")){
         
         stream.forEach(status -> assertNotNull(status.getUrl()));
      
      } 
   }
}
