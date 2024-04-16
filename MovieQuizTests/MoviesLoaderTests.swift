import Foundation
import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) //говорим что не хотим запускать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        
        //так как функция загрузки фильмов асинхронна нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            //Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                //сравниваем данные с тем что мы предполагали
                expectation.fulfill()
            case .failure(_):
                //мы не ожидаем что пришла ошибка если она появится надо будет провалить тест
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            //Then
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case .success(_):
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
}
